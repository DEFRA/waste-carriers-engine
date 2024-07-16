# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayPaymentWebhookSignatureService do
    describe ".run" do

      let(:webhook_signing_secret) { ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET") }
      let(:digest) { OpenSSL::Digest.new("sha256") }

      subject(:run_service) { described_class.run(body: webhook_body) }

      before { allow(Airbrake).to receive(:notify) }

      context "with a nil webhook body" do
        let(:webhook_body) { nil }

        it { expect { run_service }.not_to raise_error }
      end

      context "with a string webhook body" do
        let(:webhook_body) { "foo" }

        it { expect { run_service }.not_to raise_error }
      end

      context "with a complete webhook body" do
        let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read).to_s }
        let(:valid_signature) { OpenSSL::HMAC.hexdigest(digest, webhook_signing_secret, webhook_body) }

        it { expect(run_service).to eq valid_signature }

        it "does not report an error" do
          run_service

          expect(Airbrake).not_to have_received(:notify)
        end
      end
    end
  end
end
