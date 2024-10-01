# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ValidateGovpayPaymentWebhookBodyService do
    describe ".run" do
      let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read).to_s }
      let(:valid_front_office_signature) { Faker::Number.hexadecimal(digits: 20) }
      let(:valid_back_office_signature) { Faker::Number.hexadecimal(digits: 20) }
      let(:signature_service) { instance_double(GovpayPaymentWebhookSignatureService) }
      let(:signature) { nil }

      subject(:run_service) { described_class.run(body: webhook_body, signature: signature) }

      before do
        allow(GovpayPaymentWebhookSignatureService).to receive(:new).and_return(signature_service)
        allow(signature_service).to receive(:run).and_return(
          front_office: valid_front_office_signature,
          back_office: valid_back_office_signature
        )
        allow(Airbrake).to receive(:notify)
      end

      shared_examples "fails validation" do
        it "raises an exception" do
          expect { run_service }.to raise_error(ValidateGovpayPaymentWebhookBodyService::ValidationFailure)
        end

        it "logs an error" do
          run_service
          expect(Airbrake).to have_received(:notify)
        rescue ValidateGovpayPaymentWebhookBodyService::ValidationFailure
          # we expect the service to raise an exception as well as logging the error.
        end
      end

      context "with a nil signature" do
        let(:signature) { nil }

        it_behaves_like "fails validation"
      end

      context "with an invalid signature" do
        let(:signature) { "foo" }

        it_behaves_like "fails validation"
      end

      context "with a valid front office signature" do
        let(:signature) { valid_front_office_signature }

        it { expect(run_service).to be true }

        it "does not report an error" do
          run_service
          expect(Airbrake).not_to have_received(:notify)
        end
      end

      context "with a valid back office signature" do
        let(:signature) { valid_back_office_signature }

        it { expect(run_service).to be true }

        it "does not report an error" do
          run_service
          expect(Airbrake).not_to have_received(:notify)
        end
      end
    end
  end
end
