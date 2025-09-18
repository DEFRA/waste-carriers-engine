# frozen_string_literal: true

require "rails_helper"

RSpec::Matchers.define :have_webhook_body_sanitized do
  match do |notify_args|
    webhook_body = notify_args[:webhook_body]["resource"]
    webhook_body.is_a?(Hash) &&
      !webhook_body.key?("email") &&
      !webhook_body.key?("card_details") &&
      webhook_body.key?("amount") &&
      webhook_body.key?("description") &&
      webhook_body.key?("reference")
  end

  failure_message do
    "expected webhook body to have sensitive fields removed and non-sensitive fields preserved"
  end
end

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

      let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read) }

      before do
        allow(FeatureToggle).to receive(:active?).with(:detailed_logging)
        allow(GovpayPaymentWebhookHandler).to receive(:run)
        allow(GovpayRefundWebhookHandler).to receive(:run)
      end

      context "with an invalid webhook body" do
        before do
          webhook_body["event_type"] = nil

          allow(Airbrake).to receive(:notify)
          allow(FeatureToggle).to receive(:active?).with(:detailed_logging).and_return(false)
        end

        it "notifies Airbrake with basic params" do
          perform_now
          expect(Airbrake).to have_received(:notify)
            .with(
              an_instance_of(ArgumentError),
              hash_including(
                payment_id: webhook_body["resource_id"],
                service_type: "front_office"
              )
            )
        end

        context "when enhanced logging is enabled" do
          before { allow(FeatureToggle).to receive(:active?).with(:detailed_logging).and_return(true) }

          context "with sensitive information in webhook body" do

            it "sanitizes the webhook body correctly" do
              captured_args = nil
              allow(Airbrake).to receive(:notify) { |*args| captured_args = args }
              perform_now
              webhook_body = captured_args[1][:webhook_body]
              expect(webhook_body["resource"]).not_to include("email", "card_details")
              expect(webhook_body["resource"]).to include(
                "amount" => 47_600,
                "description" => "Pay your council tax",
                "reference" => "1c9229b1-ee51-4235-a31a-e8d5f35de0cc"
              )
            end

            it "includes the payment_id outside the webhook body" do
              captured_args = nil
              allow(Airbrake).to receive(:notify) { |*args| captured_args = args }
              perform_now

              expect(captured_args[1][:payment_id]).to eq(webhook_body["resource"]["payment_id"])
            end
          end

          it "includes webhook body in Airbrake notification" do
            perform_now
            expect(Airbrake).to have_received(:notify)
              .with(
                an_instance_of(ArgumentError),
                hash_including(
                  payment_id: webhook_body["resource_id"],
                  service_type: "front_office"
                )
              )
          end
        end

        context "with service type detection" do
          shared_examples "logs correct service type" do |moto, expected_service|
            before { webhook_body["resource"]["moto"] = moto }

            it "includes correct service type in Airbrake notification" do
              perform_now
              expect(Airbrake).to have_received(:notify)
                .with(
                  an_instance_of(ArgumentError),
                  hash_including(service_type: expected_service)
                )
            end
          end

          context "with a front office payment" do
            it_behaves_like "logs correct service type", false, "front_office"
          end

          context "with a back office payment" do
            it_behaves_like "logs correct service type", true, "back_office"
          end
        end
      end

      context "with a payment webhook" do
        let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read) }

        it "processes the payment webhook using GovpayPaymentWebhookHandler" do
          perform_now
          expect(GovpayPaymentWebhookHandler).to have_received(:run).with(webhook_body)
        end
      end

      context "with a refund webhook" do
        let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_refund_update_body.json").read) }

        it "processes the refund webhook using GovpayRefundWebhookHandler" do
          perform_now
          expect(GovpayRefundWebhookHandler).to have_received(:run).with(webhook_body)
        end
      end
    end
  end
end
