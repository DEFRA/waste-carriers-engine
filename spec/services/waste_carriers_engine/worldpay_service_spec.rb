require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WorldpayService do
    let(:transient_registration) do
      create(:transient_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end

    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

      WasteCarriersEngine::FinanceDetails.new_finance_details(transient_registration, :worldpay)
    end

    let(:order) { transient_registration.finance_details.orders.first }
    let(:params) {}

    let(:worldpay_service) { WorldpayService.new(transient_registration, order, params) }

    describe "prepare_for_payment" do
      context "when the request is valid" do
        let(:root) { Rails.configuration.wcrs_renewals_url }
        let(:reg_id) { transient_registration.reg_identifier }

        # Stub the WorldpayUrlService as we're testing that separately
        before do
          allow_any_instance_of(WorldpayUrlService).to receive(:format_link).and_return("LINK GOES HERE")
        end

        it "returns a link" do
          VCR.use_cassette("worldpay_initial_request") do
            url = worldpay_service.prepare_for_payment[:url]
            expect(url).to eq("LINK GOES HERE")
          end
        end

        it "creates a new payment" do
          VCR.use_cassette("worldpay_initial_request") do
            number_of_existing_payments = transient_registration.finance_details.payments.length
            worldpay_service.prepare_for_payment
            expect(transient_registration.finance_details.payments.length).to eq(number_of_existing_payments + 1)
          end
        end
      end

      context "when the request is invalid" do
        before do
          allow_any_instance_of(WorldpayXmlService).to receive(:build_xml).and_return("foo")
        end

        it "returns :error" do
          VCR.use_cassette("worldpay_initial_request_invalid") do
            expect(worldpay_service.prepare_for_payment).to eq(:error)
          end
        end
      end
    end

    describe "valid_success?" do
      # Only include the params we need to test this service, as we stub the validator
      let(:params) do
        {
          orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
          paymentStatus: "AUTHORISED",
          paymentAmount: order.total_amount,
          reg_identifier: transient_registration.reg_identifier
        }
      end

      context "when the params are valid" do
        before do
          allow_any_instance_of(WorldpayValidatorService).to receive(:valid_success?).and_return(true)
        end

        it "returns true" do
          expect(worldpay_service.valid_success?).to eq(true)
        end

        it "updates the payment status" do
          worldpay_service.valid_success?
          expect(transient_registration.reload.finance_details.payments.first.world_pay_payment_status).to eq("AUTHORISED")
        end

        it "updates the order status" do
          worldpay_service.valid_success?
          expect(transient_registration.reload.finance_details.orders.first.world_pay_status).to eq("AUTHORISED")
        end

        it "updates the balance" do
          worldpay_service.valid_success?
          expect(transient_registration.reload.finance_details.balance).to eq(0)
        end
      end

      context "when the params are invalid" do
        before do
          allow_any_instance_of(WorldpayValidatorService).to receive(:valid_success?).and_return(false)
        end

        it "returns false" do
          expect(worldpay_service.valid_success?).to eq(false)
        end

        it "does not update the order" do
          unmodified_order = transient_registration.finance_details.orders.first
          worldpay_service.valid_success?
          expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
        end

        it "does not create a payment" do
          worldpay_service.valid_success?
          expect(transient_registration.reload.finance_details.payments.count).to eq(0)
        end
      end
    end

    describe "valid_failure?" do
      # Only include the params we need to test this service, as we stub the validator
      let(:params) do
        {
          orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
          paymentStatus: "REFUSED",
          paymentAmount: order.total_amount,
          reg_identifier: transient_registration.reg_identifier
        }
      end

      context "when the params are valid" do
        before do
          allow_any_instance_of(WorldpayValidatorService).to receive(:valid_failure?).and_return(true)
        end

        it "returns true" do
          expect(worldpay_service.valid_failure?).to eq(true)
        end

        it "updates the order status" do
          worldpay_service.valid_failure?
          expect(transient_registration.reload.finance_details.orders.first.world_pay_status).to eq("REFUSED")
        end
      end

      context "when the params are invalid" do
        before do
          allow_any_instance_of(WorldpayValidatorService).to receive(:valid_failure?).and_return(false)
        end

        it "returns false" do
          expect(worldpay_service.valid_failure?).to eq(false)
        end

        it "does not update the order" do
          unmodified_order = transient_registration.finance_details.orders.first
          worldpay_service.valid_failure?
          expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
        end
      end
    end
  end
end
