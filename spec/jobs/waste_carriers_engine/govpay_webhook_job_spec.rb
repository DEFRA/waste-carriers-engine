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

      let(:payment_service_result) { { id: "123", status: "success" } }
      let(:refund_service_result) { { id: "345", payment_id: "789", status: "success" } }

      before do
        allow(FeatureToggle).to receive(:active?).with(:detailed_logging)
        allow(GovpayPaymentWebhookHandler).to receive(:process).and_return(payment_service_result)
        allow(GovpayRefundWebhookHandler).to receive(:process).and_return(refund_service_result)
        allow(Rails.logger).to receive(:info)
      end

      context "when handling errors" do
        before do
          allow(Airbrake).to receive(:notify)
          allow(FeatureToggle).to receive(:active?).with(:detailed_logging).and_return(false)
          allow(GovpayPaymentWebhookHandler).to receive(:process).and_raise(StandardError.new("Test error"))
          allow(GovpayRefundWebhookHandler).to receive(:process).and_raise(StandardError.new("Test error"))
        end

        context "with an unrecognised webhook body" do
          let(:webhook_body) { { "foo" => "bar" } }

          it "notifies Airbrake with basic params" do
            perform_now
            expect(Airbrake).to have_received(:notify)
              .with(an_instance_of(ArgumentError), refund_id: nil, payment_id: nil, service_type: "front_office")
          end

          context "when enhanced logging is enabled" do
            before { allow(FeatureToggle).to receive(:active?).with(:detailed_logging).and_return(true) }

            context "with sensitive information in webhook body" do
              let(:webhook_body) do
                json = JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read)
                json
              end

              it "sanitizes the webhook body correctly" do
                captured_args = nil
                allow(Airbrake).to receive(:notify) { |*args| captured_args = args }
                perform_now

                webhook_body = captured_args[1][:webhook_body]
                expect(webhook_body["resource"]).not_to include("email", "card_details")
                expect(webhook_body["resource"]).to include(
                  "amount" => 5000,
                  "description" => "Pay your council tax",
                  "reference" => "12345"
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
                    refund_id: nil,
                    payment_id: nil,
                    service_type: "front_office",
                    webhook_body: { "foo" => "bar" }
                  )
                )
            end
          end
        end

        context "with service type detection" do
          shared_examples "logs correct service type" do |moto, expected_service|
            let(:webhook_body) do
              {
                "resource_type" => "payment",
                "resource" => { "moto" => moto }
              }
            end

            it "includes correct service type in Airbrake notification" do
              perform_now
              expect(Airbrake).to have_received(:notify)
                .with(
                  an_instance_of(StandardError),
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
        let(:payment_service_result) { { id: "hu20sqlact5260q2nanm0q8u93", status: "submitted" } }

        it "processes the payment webhook using GovpayPaymentWebhookHandler" do
          perform_now
          expect(GovpayPaymentWebhookHandler).to have_received(:process).with(webhook_body)
        end

        it "logs the payment webhook processing" do
          perform_now
          expect(Rails.logger).to have_received(:info).with(/Processed payment webhook for payment_id: hu20sqlact5260q2nanm0q8u93, status:/)
        end
      end

      context "with a refund webhook" do
        let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_refund_update_body.json").read) }
        let(:refund_service_result) { { id: "345", payment_id: "789", status: "success" } }

        it "processes the refund webhook using GovpayRefundWebhookHandler" do
          perform_now
          expect(GovpayRefundWebhookHandler).to have_received(:process).with(webhook_body)
        end

        it "logs the refund webhook processing" do
          perform_now
          expect(Rails.logger).to have_received(:info).with(/Processed refund webhook for refund_id: 345, status:/)
        end
      end
    end
  end
end
