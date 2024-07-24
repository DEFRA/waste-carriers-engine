# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayWebhookRefundService do

    describe ".run" do

      subject(:run_service) { described_class.run(webhook_body) }

      let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_refund_update_body.json").read) }
      let(:govpay_refund_id) { webhook_body["refund_id"] }
      let(:govpay_payment_id) { webhook_body["payment_id"] }
      let(:registration) { create(:registration, :has_required_data) }
      let!(:wcr_original_payment) do
        create(:payment, :govpay,
               finance_details: registration.finance_details,
               govpay_id: govpay_payment_id,
               govpay_payment_status: "complete")
      end
      let(:prior_payment_status) { nil }
      let!(:wcr_payment) do
        create(:payment, :govpay_refund,
               finance_details: registration.finance_details,
               govpay_id: govpay_refund_id,
               refunded_payment_govpay_id: wcr_original_payment.govpay_id,
               govpay_payment_status: prior_payment_status)
      end

      include_examples "Govpay webhook services error logging"

      context "when the update is not for a refund" do
        before { webhook_body.delete("refund_id") }

        it { expect { run_service }.to raise_error(ArgumentError) }

        it_behaves_like "logs an error"
      end

      context "when the update is for a refund" do
        context "when status is not present in the update" do
          before { webhook_body["status"] = nil }

          it { expect { run_service }.to raise_error(ArgumentError) }

          it_behaves_like "logs an error"
        end

        context "when status is present in the update" do
          context "when the refund is not found" do
            before { webhook_body["refund_id"] = "foo" }

            it { expect { run_service }.to raise_error(ArgumentError) }

            it_behaves_like "logs an error"
          end

          context "when the refund is found" do
            context "when the refund status has not changed" do
              let(:prior_payment_status) { "success" }

              it { expect { run_service }.not_to change(wcr_payment, :govpay_payment_status) }

              it "writes a warning to the Rails log" do
                run_service

                expect(Rails.logger).to have_received(:warn)
              end
            end

            context "when the refund status has changed" do

              include_examples "Govpay webhook status transitions"

              # unfinished statuses
              it_behaves_like "valid and invalid transitions", "submitted", %w[success error], %w[]

              # finished statuses
              it_behaves_like "no valid transitions", "success"
              it_behaves_like "no valid transitions", "error"
            end
          end
        end
      end
    end

    # used by shared examples - different for payment vs refund webhooks
    def assign_webhook_status(status)
      webhook_body["status"] = status
    end
  end
end
