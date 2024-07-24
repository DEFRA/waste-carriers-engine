# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine

  RSpec.describe GovpayWebhookJob do
    describe ".perform_later" do
      subject(:perform_later) { described_class.perform_later(webhook_body) }

      let(:webhook_body) { { foo: :bar } }

      it { expect { perform_later }.not_to raise_error }

      it { expect { perform_later }.to have_enqueued_job(described_class).exactly(:once) }
    end

    describe ".perform_now" do
      subject(:perform_now) { described_class.perform_now(webhook_body) }

      let(:payment_webhook_service) { instance_double(WasteCarriersEngine::GovpayWebhookPaymentService) }
      let(:refund_webhook_service) { instance_double(WasteCarriersEngine::GovpayWebhookRefundService) }

      before do
        allow(WasteCarriersEngine::GovpayWebhookPaymentService).to receive(:new).and_return(payment_webhook_service)
        allow(payment_webhook_service).to receive(:run)
        allow(WasteCarriersEngine::GovpayWebhookRefundService).to receive(:new).and_return(refund_webhook_service)
        allow(refund_webhook_service).to receive(:run)
      end

      context "with an unrecognised webhook body" do
        let(:webhook_body) { { foo: :bar } }

        before { allow(Airbrake).to receive(:notify) }

        it { expect { perform_later }.to raise_error(StandardError) }

        it "notifies Airbrake" do
          perform_now

          expect(Airbrake).to have_received(:notify)
        end
      end

      context "with a payment webhook_body" do
        let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read) }

        it "calls the payment webhook service" do
          perform_now

          expect(payment_webhook_service).to have_received(:run)
        end
      end

      context "with a refund webhook_body" do
        let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_refund_update_body.json").read) }

        it "calls the refund webhook service" do
          perform_now

          expect(refund_webhook_service).to have_received(:run)
        end
      end
    end
  end
end
