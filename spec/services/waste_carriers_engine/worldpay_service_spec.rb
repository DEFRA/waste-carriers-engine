# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WorldpayService do
    let(:host) { "https://secure-test.worldpay.com" }
    before { allow(Rails.configuration).to receive(:worldpay_url).and_return(host) }

    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:current_user) { build(:user) }

    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

      transient_registration.prepare_for_payment(:worldpay, current_user)
    end

    let(:order) { transient_registration.finance_details.orders.first }
    # An incomplete set of params which should still be valid when we stub the validation service
    let(:params) do
      {
        orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
        paymentStatus: "REFUSED",
        paymentAmount: order.total_amount,
        reg_identifier: transient_registration.reg_identifier
      }
    end

    let(:worldpay_service) { described_class.new(transient_registration, order, current_user, params) }

    describe "prepare_params" do
      context "when the params are nil" do
        let(:params) { nil }

        it "sets params to nil" do
          expect(worldpay_service.instance_variable_get(:@params)).to eq(nil)
        end
      end

      context "when the params are for a non-cancelled response" do
        let(:params) do
          {
            orderKey: "foo^bar^#{order.order_code}",
            paymentStatus: "AUTHORISED",
            paymentAmount: order.total_amount,
            paymentCurrency: "GBP",
            mac: "baz",
            source: "WP",
            reg_identifier: transient_registration.reg_identifier
          }
        end

        it "does not modify the params" do
          expect(worldpay_service.instance_variable_get(:@params)).to eq(params)
        end
      end

      context "when the params are for a cancelled response" do
        let(:params) do
          {
            orderKey: "foo^bar^#{order.order_code}",
            orderAmount: order.total_amount,
            orderCurrency: "GBP",
            mac: "baz",
            source: "WP",
            reg_identifier: transient_registration.reg_identifier
          }
        end

        it "modifies the params" do
          modified_params = {
            orderKey: "foo^bar^#{order.order_code}",
            orderAmount: order.total_amount,
            orderCurrency: "GBP",
            paymentStatus: "CANCELLED",
            paymentAmount: order.total_amount,
            paymentCurrency: "GBP",
            mac: "baz",
            source: "WP",
            reg_identifier: transient_registration.reg_identifier
          }
          expect(worldpay_service.instance_variable_get(:@params)).to eq(modified_params)
        end
      end
    end

    describe "prepare_for_payment" do
      context "when the request is valid" do
        let(:root) { Rails.configuration.wcrs_renewals_url }
        let(:reg_id) { transient_registration.reg_identifier }
        let(:worldpay_url_service) { instance_double(WorldpayUrlService) }

        # Stub the WorldpayUrlService as we're testing that separately
        before do
          allow(WorldpayUrlService).to receive(:new).and_return(worldpay_url_service)
          allow(worldpay_url_service).to receive(:format_link).and_return("LINK GOES HERE")

          stub_request(:any, /.*#{host}.*/).to_return(
            status: 200,
            body: File.read("./spec/fixtures/files/worldpay/worldpay_initial_request.xml")
          )
        end

        it "returns a link" do
          url = worldpay_service.prepare_for_payment[:url]
          expect(url).to eq("LINK GOES HERE")
        end

        it "creates a new payment" do
          number_of_existing_payments = transient_registration.finance_details.payments.length
          worldpay_service.prepare_for_payment
          expect(transient_registration.finance_details.payments.length).to eq(number_of_existing_payments + 1)
        end
      end

      context "when the request is invalid" do
        let(:worldpay_xml_service) { instance_double(WorldpayXmlService) }

        before do
          allow(WorldpayXmlService).to receive(:new).and_return(worldpay_xml_service)
          allow(worldpay_xml_service).to receive(:build_xml).and_return("foo")

          stub_request(:any, /.*#{host}.*/).to_return(
            status: 200,
            body: File.read("./spec/fixtures/files/worldpay/worldpay_initial_request_invalid.xml")
          )
        end

        it "returns :error" do
          expect(worldpay_service.prepare_for_payment).to eq(:error)
        end
      end
    end

    describe "valid_success?" do
      let(:worldpay_validator_service) { instance_double(WorldpayValidatorService) }

      before do
        allow(WorldpayValidatorService).to receive(:new).and_return(worldpay_validator_service)
        params[:paymentStatus] = "AUTHORISED"
      end

      context "when the params are valid" do
        before do
          allow(worldpay_validator_service).to receive(:valid_success?).and_return(true)
        end

        it "returns true" do
          expect(worldpay_service.valid_success?).to be true
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
          allow(worldpay_validator_service).to receive(:valid_success?).and_return(false)
        end

        it "returns false" do
          expect(worldpay_service.valid_success?).to be false
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

    describe "#valid_failure?" do
      it_should_behave_like "WorldpayService valid unsuccessful action", :valid_failure?, "REFUSED"
    end

    describe "#valid_pending?" do
      it_should_behave_like "WorldpayService valid unsuccessful action", :valid_pending?, "SENT_FOR_AUTHORISATION"
    end

    describe "#valid_cancel?" do
      it_should_behave_like "WorldpayService valid unsuccessful action", :valid_cancel?, "CANCELLED"
    end

    describe "#valid_error?" do
      it_should_behave_like "WorldpayService valid unsuccessful action", :valid_error?, "ERROR"
    end
  end
end
