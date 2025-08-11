# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "GovpayWebhookCallbacks" do

    describe "/govpay_payment_update" do
      subject(:webhook_request) { post webhook_route, headers: headers, params: webhook_body }

      let(:webhook_route) { "/govpay_payment_update" }
      let(:webhook_body) { file_fixture("govpay/webhook_payment_update_body.json").read }
      let(:webhook_signing_secret) { ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET") }
      let(:digest) { OpenSSL::Digest.new("sha256") }
      let(:valid_signature) { OpenSSL::HMAC.hexdigest(digest, webhook_signing_secret, webhook_body) }
      let(:headers) do
        {
          "Pay-Signature" => valid_signature,
          "Content-Type" => "application/json"
        }
      end

      let(:webhook_validation_service) { class_double(DefraRubyGovpay::WebhookBodyValidatorService) }

      before do
        allow(Airbrake).to receive(:notify)
        if validation_success
          allow(webhook_validation_service).to receive(:run).and_return(true)
        else
          allow(webhook_validation_service).to receive(:run).and_raise(DefraRubyGovpay::WebhookBodyValidatorService::ValidationFailure)
        end
      end

      shared_examples "fails validation" do
        let(:validation_success) { false }

        it { expect { webhook_request }.not_to have_enqueued_job(GovpayWebhookJob) }
        it { expect(Airbrake).to have_received(:notify) }
        it { expect(response).to have_http_status(:ok) }
      end

      context "with no Pay-Signature" do
        let(:headers) { {} }

        before { webhook_request }

        it_behaves_like "fails validation"
      end

      context "with an invalid Pay-Signature" do
        let(:headers) { { "Pay-Signature": "foo" } }

        before { webhook_request }

        it_behaves_like "fails validation"
      end

      context "with a valid Pay-Signature" do
        let(:headers) { { "Pay-Signature": valid_signature } }
        let(:validation_success) { true }

        it "returns HTTP 200" do
          webhook_request

          expect(response).to have_http_status(:ok)
        end

        it "does not log an error" do
          webhook_request

          expect(Airbrake).not_to have_received(:notify)
        end

        it "enqueues a GovpayWebhookJob" do
          expect { webhook_request }.to have_enqueued_job(GovpayWebhookJob).exactly(:once)
        end
      end
    end
  end
end
