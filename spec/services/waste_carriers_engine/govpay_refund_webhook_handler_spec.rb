# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayRefundWebhookHandler do
    describe ".process" do
      let(:govpay_payment_id) { "govpay-payment-#{SecureRandom.uuid}" }
      let(:govpay_refund_id) { "govpay-refund-#{SecureRandom.uuid}" }
      let(:status) { "success" }
      let(:webhook_body) do
        {
          "refund_id" => govpay_refund_id,
          "payment_id" => govpay_payment_id,
          "status" => status
        }
      end
      let(:previous_status) { "submitted" }

      let(:payment) { build(:payment, :govpay, govpay_id: govpay_payment_id, govpay_payment_status: "success") }
      let(:refund) { build(:payment, :govpay_refund_pending, govpay_id: govpay_refund_id, refunded_payment_govpay_id: govpay_payment_id, govpay_payment_status: previous_status) }
      let(:registration) { create(:registration, :has_required_data, finance_details: build(:finance_details, :has_required_data)) }
      let(:update_service) { instance_double(GovpayUpdateRefundStatusService) }

      before do
        registration.finance_details.payments << payment
        registration.finance_details.payments << refund
        registration.finance_details.update_balance
        registration.save!

        allow(GovpayUpdateRefundStatusService).to receive(:new).and_return(update_service)
        allow(DefraRubyGovpay::GovpayWebhookRefundService).to receive(:run)
          .with(webhook_body, previous_status: previous_status)
          .and_return({ id: govpay_refund_id, payment_id: govpay_payment_id, status: status })

        allow(GovpayFindPaymentService).to receive(:run).with(payment_id: govpay_refund_id).and_return(refund)
        allow(GovpayFindRegistrationService).to receive(:run).with(payment: refund).and_return(registration)
      end

      it "processes the refund through GovpayUpdateRefundStatusService" do
        allow(update_service).to receive(:run).with(
          registration: registration,
          refund_id: govpay_refund_id,
          new_status: status
        ).and_return(true)

        described_class.process(webhook_body)

        expect(update_service).to have_received(:run).with(
          registration: registration,
          refund_id: govpay_refund_id,
          new_status: status
        )
      end

      context "when the refund is not found" do
        before { allow(GovpayFindPaymentService).to receive(:run).with(payment_id: govpay_refund_id).and_return(nil) }
        # When refund is not found, previous_status will be nil
        let(:previous_status) { nil }

        it "returns early without updating the refund status" do
          allow(update_service).to receive(:run)

          described_class.process(webhook_body)

          expect(update_service).not_to have_received(:run)
        end
      end

      context "when the registration is not found" do
        before { allow(GovpayFindRegistrationService).to receive(:run).with(payment: refund).and_return(nil) }

        it "returns early without updating the refund status" do
          update_service = instance_double(GovpayUpdateRefundStatusService)
          allow(GovpayUpdateRefundStatusService).to receive(:new).and_return(update_service)
          allow(update_service).to receive(:run)

          described_class.process(webhook_body)

          expect(update_service).not_to have_received(:run)
        end
      end

      context "when an error occurs" do
        before do
          allow(update_service).to receive(:run).and_raise(StandardError.new("Test error"))
          allow(Airbrake).to receive(:notify)
          allow(DefraRubyGovpay::GovpayWebhookRefundService).to receive(:run)
            .with(webhook_body, previous_status: "submitted")
            .and_raise(StandardError, "Something went wrong")
        end

        it "catches the error and continues" do
          expect { described_class.process(webhook_body) }.not_to raise_error
        end
      end
    end
  end
end
