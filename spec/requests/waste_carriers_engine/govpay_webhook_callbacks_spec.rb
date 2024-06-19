# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "GovpayWebhookCallbacks" do

    describe "/govpay_payment_update" do

      let(:webhook_route) { "/govpay_payment_update" }
      let(:headers) { "Pay-Signature" => signature }
      let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read).to_s }
      let(:webhook_signing_secret) { ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET") }
      let(:digest) { OpenSSL::Digest.new("sha256") }
      let(:valid_signature) { OpenSSL::HMAC.digest(digest, webhook_signing_secret, webhook_body) }

      let(:webhook_validation_service) { instance_double(ValidateGovpayPaymentWebhookBodyService) }

      before do
        allow(Airbrake).to receive(:notify)
        allow(ValidateGovpayPaymentWebhookBodyService).to receive(:new).and_return webhook_validation_service
        if validation_success
          allow(webhook_validation_service).to receive(:run).and_return(true)
        else
          allow(webhook_validation_service).to receive(:run).and_raise(ValidateGovpayPaymentWebhookBodyService::ValidationFailure)
        end

        post webhook_route, headers: headers
      end

      shared_examples "fails validation" do
        let(:validation_success) { false }

        it { expect(Airbrake).to have_received(:notify) }
        it { expect(response).to have_http_status(:ok) }
      end

      context "with no Pay-Signature" do
        let(:headers) { {} }

        it_behaves_like "fails validation"
      end

      context "with an invalid Pay-Signature" do
        let(:headers) { { "Pay-Signature": "foo" } }

        it_behaves_like "fails validation"
      end

      context "with a valid Pay-Signature" do
        let(:headers) { { "Pay-Signature": valid_signature } }
        let(:validation_success) { true }

        it { expect(response).to have_http_status(:ok) }

        it "does not log an error" do
          expect(Airbrake).not_to have_received(:notify)
        end
      end
    end
  end
end
