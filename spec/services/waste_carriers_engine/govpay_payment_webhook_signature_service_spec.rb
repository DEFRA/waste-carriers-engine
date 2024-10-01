# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayPaymentWebhookSignatureService do
    describe ".run" do
      let(:front_office_secret) { ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET") }
      let(:back_office_secret) { ENV.fetch("WCRS_GOVPAY_BACK_OFFICE_CALLBACK_WEBHOOK_SIGNING_SECRET") }
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
        let(:valid_front_office_signature) { OpenSSL::HMAC.hexdigest(digest, front_office_secret, webhook_body) }
        let(:valid_back_office_signature) { OpenSSL::HMAC.hexdigest(digest, back_office_secret, webhook_body) }

        it "returns correct signatures for both front office and back office" do
          result = run_service
          expect(result[:front_office]).to eq valid_front_office_signature
          expect(result[:back_office]).to eq valid_back_office_signature
        end

        it "does not report an error" do
          run_service
          expect(Airbrake).not_to have_received(:notify)
        end
      end
    end
  end
end
