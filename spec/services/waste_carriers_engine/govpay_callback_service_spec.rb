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
    let(:order) { transient_registration.finance_details.orders.first }

    before do
      allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true)
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)
      transient_registration.prepare_for_payment(:govpay, current_user)
      order.govpay_id = "a_govpay_id"
      order.save!
    end

    let(:govpay_callback_service) { GovpayCallbackService.new(order.payment_uuid) }

    describe "#run" do

      RSpec.shared_examples "acceptable payment" do |response_type|
        context "when the status is valid" do
          before { allow_any_instance_of(GovpayValidatorService).to receive("valid_#{response_type}?".to_sym).and_return(true) }

          it "returns #{response_type}" do
            expect(govpay_callback_service.run).to eq(response_type)
          end

          it "updates the payment status" do
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.payments.first.govpay_payment_status).to eq(response_type.to_s)
          end

          it "updates the payment govpay_id" do
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.payments.first.govpay_id).not_to be_nil
          end

          it "updates the order govpay_status" do
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.orders.first.govpay_status).to eq(response_type.to_s)
          end

          it "updates the order govpay_id" do
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.orders.first.govpay_id).not_to be_nil
          end
        end

        context "when the status is invalid" do
          before { allow_any_instance_of(GovpayValidatorService).to receive("valid_#{response_type}?".to_sym).and_return(false) }

          it "returns an error" do
            expect(govpay_callback_service.run).to eq(:error)
          end

          it "does not update the order" do
            unmodified_order = transient_registration.finance_details.orders.first
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
          end

          it "does not create a payment" do
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.payments.count).to eq(0)
          end
        end
      end

      context "success" do
        before { allow_any_instance_of(GovpayPaymentDetailsService).to receive(:govpay_payment_status).and_return("success") }

        it_behaves_like "acceptable payment", :success

        it "updates the balance" do
          govpay_callback_service.run
          expect(transient_registration.reload.finance_details.balance).to eq(0)
        end
      end

      context "created" do
        before { allow_any_instance_of(GovpayPaymentDetailsService).to receive(:govpay_payment_status).and_return("created") }
        it_behaves_like "acceptable payment", :pending
      end

      context "submitted" do
        before { allow_any_instance_of(GovpayPaymentDetailsService).to receive(:govpay_payment_status).and_return("submitted") }
        it_behaves_like "acceptable payment", :pending
      end

      RSpec.shared_examples "unsuccessful payment" do |response_type|

        context "when the status is valid" do
          before do
            allow_any_instance_of(GovpayValidatorService).to receive("valid_#{response_type}?".to_sym).and_return(true)
          end

          it "returns #{response_type}" do
            expect(govpay_callback_service.run).to eq(response_type)
          end

          it "updates the order status" do
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.orders.first.govpay_status).to eq(response_type.to_s)
          end
        end

        context "when the status is invalid" do
          before do
            allow_any_instance_of(GovpayValidatorService).to receive("valid_#{response_type}?".to_sym).and_return(false)
          end

          it "returns an error" do
            expect(govpay_callback_service.run).to eq(:error)
          end

          it "does not update the order" do
            unmodified_order = transient_registration.finance_details.orders.first
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
          end

          it "does not create a payment" do
            govpay_callback_service.run
            expect(transient_registration.reload.finance_details.payments.count).to eq(0)
          end
        end
      end

      context "failed" do
        before { allow_any_instance_of(GovpayPaymentDetailsService).to receive(:govpay_payment_status).and_return("failed") }
        it_behaves_like "unsuccessful payment", :failure
      end

      context "cancelled" do
        before { allow_any_instance_of(GovpayPaymentDetailsService).to receive(:govpay_payment_status).and_return("cancelled") }
        it_behaves_like "unsuccessful payment", :cancel
      end

      context "error" do
        before { allow_any_instance_of(GovpayPaymentDetailsService).to receive(:govpay_payment_status).and_return("error") }
        it_behaves_like "unsuccessful payment", :error
      end
    end
  end
end
