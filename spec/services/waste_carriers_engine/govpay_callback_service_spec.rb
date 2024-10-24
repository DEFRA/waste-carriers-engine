# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayCallbackService do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    let(:payment_uuid) { order.payment_uuid }
    let(:action) { "success" }
    let(:govpay_callback_service) { described_class.new(payment_uuid, action) }
    let(:govpay_payment_details_service) { instance_double(GovpayPaymentDetailsService) }
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:order) { transient_registration.finance_details.orders.first }
    let(:govpay_validator_service) { instance_double(GovpayValidatorService) }

    before do
      allow(GovpayPaymentDetailsService).to receive(:new).and_return(govpay_payment_details_service)
      allow(GovpayValidatorService).to receive(:new).and_return(govpay_validator_service)
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)
      transient_registration.prepare_for_payment(:govpay)
      order.govpay_id = "a_govpay_id"
      order.save!
      allow(govpay_payment_details_service).to receive(:govpay_payment_status).and_return(Payment::STATUS_CREATED)
    end

    describe "#process_payment" do
      context "when the response is valid" do
        before do
          allow(govpay_validator_service).to receive(:valid_success?).and_return(true)
        end

        it "returns true" do
          expect(govpay_callback_service.process_payment).to be true
        end

        it "updates the payment status" do
          govpay_callback_service.process_payment
          expect(transient_registration.reload.finance_details.payments.first.govpay_payment_status).to eq(Payment::STATUS_SUCCESS)
        end

        it "updates the order status" do
          govpay_callback_service.process_payment
          expect(transient_registration.reload.finance_details.orders.first.govpay_status).to eq(Payment::STATUS_SUCCESS)
        end

        it "updates the balance" do
          govpay_callback_service.process_payment
          expect(transient_registration.reload.finance_details.balance).to eq(0)
        end

        context "when run in the front office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

          it "calls the GovpayPaymentDetailsService with is_moto: false" do
            govpay_callback_service.process_payment
            expect(GovpayPaymentDetailsService).to have_received(:new).with(hash_not_including(is_moto: true))
          end
        end

        context "when run in the back office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

          it "calls the GovpayPaymentDetailsService with is_moto: true" do
            govpay_callback_service.process_payment
            expect(GovpayPaymentDetailsService).to have_received(:new).with(hash_including(is_moto: true))
          end
        end

        context "when a new order is initiated before the first one is completed" do
          before { transient_registration.prepare_for_payment("card") }

          it { expect(govpay_callback_service.process_payment).to be true }
        end
      end

      context "when the response is invalid" do
        let(:payment_uuid) { "invalid_uuid" }

        before do
          allow(govpay_validator_service).to receive(:valid_success?).and_return(false)
        end

        it "returns false" do
          expect(govpay_callback_service.process_payment).to be false
        end

        it "does not update the order" do
          unmodified_order = transient_registration.finance_details.orders.first
          govpay_callback_service.process_payment
          expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
        end

        it "does not create a payment" do
          govpay_callback_service.process_payment
          expect(transient_registration.reload.finance_details.payments.count).to eq(0)
        end
      end

      context "when the action is not success" do
        let(:action) { "failure" }

        before do
          allow(govpay_validator_service).to receive(:valid_failure?).and_return(true)
        end

        it "returns true" do
          expect(govpay_callback_service.process_payment).to be true
        end

        it "updates only the order status" do
          govpay_callback_service.process_payment
          expect(transient_registration.reload.finance_details.payments).to be_empty
        end
      end
    end
  end
end
