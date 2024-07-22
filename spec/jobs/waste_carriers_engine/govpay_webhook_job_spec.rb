# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine

  RSpec.describe GovpayWebhookJob do
    describe ".perform" do
      subject(:perform_job) { described_class.perform_later(webhook_body) }

      let(:payment_webhook_service) { instance_double(WasteCarriersEngine::GovpayWebhookPaymentService) }
      let(:webhook_body) { { foo: :bar } }

      before do
        allow(WasteCarriersEngine::GovpayWebhookPaymentService).to receive(:new).and_return(payment_webhook_service)
        allow(payment_webhook_service).to receive(:run)
      end

      it "does not error" do
        expect { perform_job }.not_to raise_error
      end

      it "enqueues a job" do
        expect { perform_job }.to have_enqueued_job(described_class).exactly(:once)
      end
    end
  end
end
