# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayCallbackService do
    let(:govpay_callback_service) { described_class.new(payment_uuid, govpay_payment_status) }

    let(:govpay_payment_details_service) { instance_double(GovpayPaymentDetailsService) }
    let(:payment_uuid) { order.payment_uuid }
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:order) { transient_registration.finance_details.orders.first }
    let(:govpay_payment_status) { "submitted" }

    before do
      allow(GovpayPaymentDetailsService).to receive(:new).and_return(govpay_payment_details_service)
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)
      transient_registration.prepare_for_payment(:govpay)
      order.govpay_id = "a_govpay_id"
      order.save!
      payment = build(:payment, :govpay_pending, govpay_id: order.govpay_id, amount: order.total_amount)
      transient_registration.finance_details.payments << payment
      transient_registration.finance_details.update_balance
    end

    describe "#process_payment" do

      before do
        allow(govpay_payment_details_service).to receive(:govpay_payment_status).and_return(govpay_payment_status)
      end

      shared_examples "a valid response" do

        it "returns true" do
          expect(govpay_callback_service.process_payment).to be true
        end

        it "updates the payment status" do
          govpay_callback_service.process_payment
          expect(transient_registration.reload.finance_details.payments.first.govpay_payment_status).to eq(govpay_payment_status)
        end

        it "updates the order status" do
          govpay_callback_service.process_payment
          expect(transient_registration.reload.finance_details.orders.first.govpay_status).to eq(govpay_payment_status)
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

      context "when the response is valid" do
        context "when the govpay status is 'created'" do
          let(:govpay_payment_status) { Payment::STATUS_CREATED }

          it_behaves_like "a valid response"

          it "does not update the balance" do
            expect { govpay_callback_service.process_payment }
              .not_to change { transient_registration.reload.finance_details.balance }
          end
        end

        context "when the govpay status is 'started'" do
          let(:govpay_payment_status) { Payment::STATUS_STARTED }

          it_behaves_like "a valid response"

          it "does not update the balance" do
            expect { govpay_callback_service.process_payment }
              .not_to change { transient_registration.reload.finance_details.balance }
          end
        end

        context "when the govpay status is 'success'" do
          let(:govpay_payment_status) { Payment::STATUS_SUCCESS }

          it_behaves_like "a valid response"

          it "updates the balance" do
            expect { govpay_callback_service.process_payment }
              .to change { transient_registration.reload.finance_details.balance }.to(0)
          end
        end
      end

      context "when the response is invalid" do
        let(:payment_uuid) { "invalid_uuid" }
        let(:govpay_payment_status) { "started" }

        before do
          allow(govpay_payment_details_service).to receive(:govpay_payment_status)
        end

        it "returns false" do
          expect(govpay_callback_service.process_payment).to be false
        end

        it "does not update the order" do
          expect { govpay_callback_service.process_payment }
            .not_to change { transient_registration.reload.finance_details.orders }
        end
      end
    end
  end
end
