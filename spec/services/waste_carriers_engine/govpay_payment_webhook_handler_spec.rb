# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayPaymentWebhookHandler do
    describe ".process" do
      let(:govpay_id) { "govpay-#{SecureRandom.uuid}" }
      let(:status) { "success" }
      let(:webhook_body) do
        {
          "resource_type" => "payment",
          "resource" => {
            "payment_id" => govpay_id,
            "state" => {
              "status" => status
            }
          }
        }
      end

      let(:payment) { build(:payment, :govpay, govpay_id: govpay_id, govpay_payment_status: "created") }
      let(:registration) { create(:registration, :has_required_data, finance_details: build(:finance_details, :has_required_data)) }

      before do
        registration.finance_details.payments << payment
        registration.finance_details.update_balance
        registration.save!

        allow(DefraRubyGovpay::GovpayWebhookPaymentService).to receive(:run)
          .with(webhook_body, previous_status: "created")
          .and_return({ id: govpay_id, status: status }
        )

        allow(GovpayFindPaymentService).to receive(:run).with(payment_id: govpay_id).and_return(payment)
        allow(GovpayFindRegistrationService).to receive(:run).with(payment: payment).and_return(registration)
      end

      it "updates the payment status and finance details balance" do
        expect { described_class.process(webhook_body) }.to change { payment.reload.govpay_payment_status }.from("created").to("success")
      end

      context "when the payment is for a renewal" do
        let(:registration) { create(:renewing_registration, :has_required_data, finance_details: build(:finance_details, :has_required_data)) }
        let(:renewal_service) { instance_double(RenewalCompletionService) }

        before do
          allow(RenewalCompletionService).to receive(:new).with(registration).and_return(renewal_service)
          allow(renewal_service).to receive(:complete_renewal)
        end

        it "completes the renewal when status is success" do
          described_class.process(webhook_body)
          expect(renewal_service).to have_received(:complete_renewal)
        end

        context "when the status is not success" do
          let(:status) { "failed" }

          it "does not complete the renewal" do
            described_class.process(webhook_body)
            expect(renewal_service).not_to have_received(:complete_renewal)
          end
        end
      end

      context "when the payment is not found" do
        before do 
          allow(GovpayFindPaymentService).to receive(:run).with(payment_id: govpay_id).and_return(nil)
          # When payment is not found, previous_status will be nil
          allow(DefraRubyGovpay::GovpayWebhookPaymentService).to receive(:run)
            .with(webhook_body, previous_status: nil)
            .and_return({ id: govpay_id, status: status })
        end

        it "returns early without updating any payment" do
          expect { described_class.process(webhook_body) }.not_to change { payment.reload.govpay_payment_status }
        end
      end

      context "when the registration is not found" do
        before { allow(GovpayFindRegistrationService).to receive(:run).with(payment: payment).and_return(nil) }

        it "returns early without updating any payment" do
          expect { described_class.process(webhook_body) }.not_to change { payment.reload.govpay_payment_status }
        end
      end

      context "when an error occurs" do
        before do
          allow(payment).to receive(:update).and_raise(StandardError.new("Test error"))
          allow(Airbrake).to receive(:notify)
        end

        it "catches the error and continues" do
          expect { described_class.process(webhook_body) }.not_to raise_error
        end
      end
    end
  end
end
