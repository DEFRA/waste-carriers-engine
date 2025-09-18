# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayRefundWebhookHandler do

    describe ".run" do

      subject(:run_service) { described_class.run(webhook_body) }

      let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_refund_update_body.json").read) }
      let(:govpay_payment_id) { webhook_body["resource_id"] }
      let(:registration) { create(:registration, :has_required_data) }
      let!(:wcr_original_payment) do
        create(:payment, :govpay,
               finance_details: registration.finance_details,
               govpay_id: govpay_payment_id,
               govpay_payment_status: Payment::STATUS_COMPLETE)
      end
      let(:prior_refund_status) { Payment::STATUS_SUBMITTED }
      let!(:wcr_payment) do
        create(:payment, :govpay_refund,
               finance_details: registration.finance_details,
               refunded_payment_govpay_id: wcr_original_payment.govpay_id,
               govpay_payment_status: prior_refund_status)
      end

      let(:update_refund_service) { instance_double(WasteCarriersEngine::GovpayUpdateRefundStatusService) }

      shared_examples "failed refund update" do
        it { expect { run_service }.to raise_error(ArgumentError) }

        it_behaves_like "logs an error"
      end

      context "when the update is not for a refund" do
        before { webhook_body["event_type"] = "card_payment_captured" }

        it_behaves_like "failed refund update"
      end

      context "when the update is for a refund" do
        before { allow(Rails.logger).to receive(:warn).and_call_original }

        context "when status is not present in the update" do
          before { webhook_body["resource"]["state"]["status"] = nil }

          it_behaves_like "failed refund update"
        end

        context "when status is present in the update" do
          context "when the original payment is not found" do
            before { webhook_body["resource_id"] = "foo" }

            it_behaves_like "failed refund update"
          end

          context "when the refund is not found" do
            before { wcr_payment.update(refunded_payment_govpay_id: nil) }

            it_behaves_like "failed refund update"
          end

          context "when the refund is found" do
            context "when the refund status has not changed" do
              let(:prior_refund_status) { Payment::STATUS_SUCCESS }

              it { expect { run_service }.not_to change(wcr_payment, :govpay_payment_status) }

              it "writes a warning to the Rails log" do
                run_service

                expect(Rails.logger).to have_received(:warn)
              end
            end

            context "when the update service raises an exception" do
              before { allow(WasteCarriersEngine::GovpayUpdateRefundStatusService).to receive(:run).and_raise(StandardError) }

              it_behaves_like "logs an error"
            end

            context "when the refund status has changed" do
              # There are no valid transitions other than to success.
              # context "when the webhook changes the status to a non-success value" do

              context "when the webhook changes the status to success" do
                let(:prior_refund_status) { Payment::STATUS_SUBMITTED }

                before { assign_webhook_status("success") }

                it "updates the balance" do
                  expect { run_service }.to change { wcr_payment.finance_details.reload.balance }
                end
              end
            end
          end
        end
      end
    end
  end
end
