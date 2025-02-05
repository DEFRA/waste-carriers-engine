# frozen_string_literal: true

require "rails_helper"

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

      let(:payment_webhook_service) { instance_double(WasteCarriersEngine::GovpayWebhookPaymentService) }
      let(:refund_webhook_service) { instance_double(WasteCarriersEngine::GovpayWebhookRefundService) }

      before do
        allow(WasteCarriersEngine::GovpayWebhookPaymentService).to receive(:new).and_return(payment_webhook_service)
        allow(payment_webhook_service).to receive(:run)
        allow(WasteCarriersEngine::GovpayWebhookRefundService).to receive(:new).and_return(refund_webhook_service)
        allow(refund_webhook_service).to receive(:run)
      end

      context "when handling errors" do
        before do
          allow(Airbrake).to receive(:notify)
          allow(FeatureToggle).to receive(:active?).with("enhanced_govpay_logging").and_return(false)
        end

        context "with an unrecognised webhook body" do
          let(:webhook_body) { { "foo" => "bar" } }

          it "notifies Airbrake with basic params" do
            perform_now
            expect(Airbrake).to have_received(:notify)
              .with(an_instance_of(ArgumentError), refund_id: nil, payment_id: nil, service_type: "front_office")
          end

          context "when enhanced logging is enabled" do
            before { allow(FeatureToggle).to receive(:active?).with("enhanced_govpay_logging").and_return(true) }

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
                "resource_type" => "invalid_type",
                "resource" => { "moto" => moto }
              }
            end

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

      context "with a payment webhook_body" do
        let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read) }

        it "calls the payment webhook service" do
          perform_now

          expect(payment_webhook_service).to have_received(:run)
        end
      end

      context "with a refund webhook_body" do
        let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_refund_update_body.json").read) }

        it "calls the refund webhook service" do
          perform_now

          expect(refund_webhook_service).to have_received(:run)
        end
      end

      context "with different casings for resource_type" do
        shared_examples "a valid payment webhook" do |resource_type_value|
          let(:webhook_body) do
            {
              "resource_type" => resource_type_value,
              "refund_id" => nil # Ensure it's treated as a payment
            }
          end

          it "calls the payment webhook service" do
            perform_now

            expect(payment_webhook_service).to have_received(:run).with(webhook_body)
          end
        end

        it_behaves_like "a valid payment webhook", "payment"
        it_behaves_like "a valid payment webhook", "Payment"
        it_behaves_like "a valid payment webhook", "PAYMENT"
        it_behaves_like "a valid payment webhook", "PaYmEnT"
      end
    end
  end
end
