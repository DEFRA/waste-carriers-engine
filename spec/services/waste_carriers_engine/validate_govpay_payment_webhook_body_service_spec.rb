# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ValidateGovpayPaymentWebhookBodyService do
    describe ".run" do
      let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read).to_s }
      let(:valid_front_office_signature) { Faker::Number.hexadecimal(digits: 20) }
      let(:valid_back_office_signature) { Faker::Number.hexadecimal(digits: 20) }
      let(:signature) { "valid-signature" }

      subject(:run_service) { described_class.run(body: webhook_body, signature: signature) }

      before do
        allow(Airbrake).to receive(:notify)
      end

      shared_examples "fails validation" do
        it "raises an exception" do
          expect { run_service }.to raise_error(ValidateGovpayPaymentWebhookBodyService::ValidationFailure)
        end
      end

      context "with a nil signature" do
        let(:signature) { nil }

        before do
          allow(DefraRubyGovpay::CallbackValidator).to receive(:call).and_return(false)
        end

        it_behaves_like "fails validation"
      end

      context "with an invalid signature" do
        let(:signature) { "foo" }

        before do
          allow(DefraRubyGovpay::CallbackValidator).to receive(:call).and_return(false)
        end

        it_behaves_like "fails validation"
      end

      context "with a valid front office signature" do
        let(:signature) { valid_front_office_signature }

        before do
          allow(DefraRubyGovpay::CallbackValidator).to receive(:call)
            .with(webhook_body, ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET"), signature)
            .and_return(true)
          allow(DefraRubyGovpay::CallbackValidator).to receive(:call)
            .with(webhook_body, ENV.fetch("WCRS_GOVPAY_BACK_OFFICE_CALLBACK_WEBHOOK_SIGNING_SECRET"), signature)
            .and_return(false)
        end

        it { expect(run_service).to be true }
      end

      context "with a valid back office signature" do
        let(:signature) { valid_back_office_signature }

        before do
          allow(DefraRubyGovpay::CallbackValidator).to receive(:call)
            .with(webhook_body, ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET"), signature)
            .and_return(false)
          allow(DefraRubyGovpay::CallbackValidator).to receive(:call)
            .with(webhook_body, ENV.fetch("WCRS_GOVPAY_BACK_OFFICE_CALLBACK_WEBHOOK_SIGNING_SECRET"), signature)
            .and_return(true)
        end

        it { expect(run_service).to be true }
      end
    end
  end
end
