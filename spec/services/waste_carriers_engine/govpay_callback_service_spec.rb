# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayCallbackService do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    let(:govpay_callback_service) { described_class.new(order.payment_uuid) }
    let(:govpay_payment_details_service) { instance_double(GovpayPaymentDetailsService) }
    let(:govpay_validator_service) { instance_double(GovpayValidatorService) }

    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:current_user) { build(:user) }
    let(:order) { transient_registration.finance_details.orders.first }

    before do
      allow(GovpayPaymentDetailsService).to receive(:new).and_return(govpay_payment_details_service)
      allow(GovpayValidatorService).to receive(:new).and_return(govpay_validator_service)

      allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true)
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

      transient_registration.prepare_for_payment(:govpay, current_user)
      order.govpay_id = "a_govpay_id"
      order.save!
    end

    describe "#payment_callback" do

      before { allow(govpay_payment_details_service).to receive(:govpay_payment_status).and_return("created") }

      context "when the status is valid" do
        before { allow(govpay_validator_service).to receive(:valid_success?).and_return(true) }

        it "returns true" do
          expect(govpay_callback_service.valid_success?).to be true
        end

        it "updates the payment status" do
          govpay_callback_service.valid_success?
          expect(transient_registration.reload.finance_details.payments.first.govpay_payment_status).to eq("success")
        end

        it "updates the order status" do
          govpay_callback_service.valid_success?
          expect(transient_registration.reload.finance_details.orders.first.govpay_status).to eq("success")
        end

        it "updates the balance" do
          govpay_callback_service.valid_success?
          expect(transient_registration.reload.finance_details.balance).to eq(0)
        end
      end

      context "when the status is invalid" do
        before { allow(govpay_validator_service).to receive(:valid_success?).and_return(false) }

        it "returns false" do
          expect(govpay_callback_service.valid_success?).to be false
        end

        it "does not update the order" do
          unmodified_order = transient_registration.finance_details.orders.first
          govpay_callback_service.valid_success?
          expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
        end

        it "does not create a payment" do
          govpay_callback_service.valid_success?
          expect(transient_registration.reload.finance_details.payments.count).to eq(0)
        end
      end
    end
  end
end
