# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayCallbackService do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:current_user) { build(:user) }
    # let(:payment) { Payment.new_from_online_payment(transient_registration.finance_details.orders.first, nil) }
    let(:order) { transient_registration.finance_details.orders.first }

    before do
      allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true)
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)
      transient_registration.prepare_for_payment(:govpay, current_user)
      order.govpay_id = "a_govpay_id"
      order.save!
    end

    let(:govpay_service) { GovpayCallbackService.new(order.payment_uuid) }

    describe "#payment_callback" do
      context "valid_success?" do
        before { allow(GovpayPaymentDetailsService).to receive(:payment_status).with(order.govpay_id).and_return(:success) }

        context "when the status is valid" do
          before { allow_any_instance_of(GovpayValidatorService).to receive(:valid_success?).and_return(true) }

          it "returns true" do
            expect(govpay_service.valid_success?).to eq(true)
          end

          it "updates the payment status" do
            govpay_service.valid_success?
            expect(transient_registration.reload.finance_details.payments.first.govpay_payment_status).to eq("success")
          end

          it "updates the order status" do
            govpay_service.valid_success?
            expect(transient_registration.reload.finance_details.orders.first.govpay_status).to eq("success")
          end

          it "updates the balance" do
            govpay_service.valid_success?
            expect(transient_registration.reload.finance_details.balance).to eq(0)
          end
        end

        context "when the status is invalid" do
          before { allow_any_instance_of(GovpayValidatorService).to receive(:valid_success?).and_return(false) }

          it "returns false" do
            expect(govpay_service.valid_success?).to eq(false)
          end

          it "does not update the order" do
            unmodified_order = transient_registration.finance_details.orders.first
            govpay_service.valid_success?
            expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
          end

          it "does not create a payment" do
            govpay_service.valid_success?
            expect(transient_registration.reload.finance_details.payments.count).to eq(0)
          end
        end
      end

      # context "#valid_failure?" do
      #   it_should_behave_like "GovpayCallbackService valid unsuccessful action", :valid_failure?, "failed"
      # end

      # context "#valid_pending?" do
      #   it_should_behave_like "GovpayCallbackService valid unsuccessful action", :valid_pending?, "created"
      # end

      # context "#valid_cancel?" do
      #   it_should_behave_like "GovpayCallbackService valid unsuccessful action", :valid_cancel?, "cancelled"
      # end

      # context "#valid_error?" do
      #   it_should_behave_like "GovpayCallbackService valid unsuccessful action", :valid_error?, "error"
      # end
    end
  end
end
