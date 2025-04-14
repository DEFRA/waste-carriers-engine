# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayWebhookCallbacksController, type: :controller do
    routes { WasteCarriersEngine::Engine.routes }

    describe "POST process_webhook" do
      let(:valid_body) { file_fixture("govpay/webhook_payment_update_body.json").read }
      let(:valid_signature) { "valid-signature" }

      before do
        allow(DefraRubyGovpay::CallbackValidator).to receive(:call).and_return(true)
        allow(GovpayWebhookJob).to receive(:perform_later)
        request.headers["Pay-Signature"] = valid_signature
        request.env["RAW_POST_DATA"] = valid_body
      end

      it "returns a 200 status code" do
        post :process_webhook
        expect(response).to have_http_status(:ok)
      end

      it "enqueues a GovpayWebhookJob" do
        post :process_webhook
        expect(GovpayWebhookJob).to have_received(:perform_later).with(JSON.parse(valid_body))
      end

      context "when the Pay-Signature header is missing" do
        before do
          request.headers["Pay-Signature"] = nil
          allow(Rails.logger).to receive(:error)
          allow(Airbrake).to receive(:notify)
        end

        it "returns a 200 status code" do
          post :process_webhook
          expect(response).to have_http_status(:ok)
        end

        it "logs the error" do
          post :process_webhook
          expect(Rails.logger).to have_received(:error).with(/missing Pay-Signature header/)
        end

        it "notifies Airbrake" do
          post :process_webhook
          expect(Airbrake).to have_received(:notify)
        end

        it "does not enqueue a GovpayWebhookJob" do
          post :process_webhook
          expect(GovpayWebhookJob).not_to have_received(:perform_later)
        end
      end

      context "when the signature is invalid" do
        before do
          allow(DefraRubyGovpay::CallbackValidator).to receive(:call).and_return(false)
          allow(Rails.logger).to receive(:error)
          allow(Airbrake).to receive(:notify)
        end

        it "returns a 200 status code" do
          post :process_webhook
          expect(response).to have_http_status(:ok)
        end

        it "logs the error" do
          post :process_webhook
          expect(Rails.logger).to have_received(:error).with(/validation failed/)
        end

        it "notifies Airbrake" do
          post :process_webhook
          expect(Airbrake).to have_received(:notify)
        end

        it "does not enqueue a GovpayWebhookJob" do
          post :process_webhook
          expect(GovpayWebhookJob).not_to have_received(:perform_later)
        end
      end

      context "when validation raises an error" do
        before do
          allow(DefraRubyGovpay::CallbackValidator).to receive(:call).and_raise(StandardError.new("Test error"))
          allow(Rails.logger).to receive(:error)
          allow(Airbrake).to receive(:notify)
        end

        it "returns a 200 status code" do
          post :process_webhook
          expect(response).to have_http_status(:ok)
        end

        it "logs the error" do
          post :process_webhook
          expect(Rails.logger).to have_received(:error).with(/validation failed/)
        end

        it "notifies Airbrake" do
          post :process_webhook
          expect(Airbrake).to have_received(:notify)
        end

        it "does not enqueue a GovpayWebhookJob" do
          post :process_webhook
          expect(GovpayWebhookJob).not_to have_received(:perform_later)
        end
      end
    end
  end
end
