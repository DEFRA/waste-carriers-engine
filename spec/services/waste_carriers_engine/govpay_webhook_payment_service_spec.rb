# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayWebhookPaymentService do
    describe ".run" do

      subject(:run_service) { described_class.run(webhook_body) }

      let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read) }
      let(:webhook_resource) { webhook_body["resource"] }
      let(:govpay_payment_id) { webhook_body["resource"]["payment_id"] }
      let(:registration) { create(:registration, :has_required_data) }
      let(:prior_payment_status) { nil }
      let!(:wcr_payment) do
        create(:payment, :govpay,
               finance_details: registration.finance_details,
               govpay_id: govpay_payment_id,
               govpay_payment_status: prior_payment_status)
      end

      include_examples "Govpay webhook services error logging"

      context "when the update is not for a payment" do
        before { webhook_body["resource_type"] = "refund" }

        it { expect { run_service }.to raise_error(ArgumentError) }

        it_behaves_like "logs an error"
      end

      context "when the update is for a payment" do
        context "when status is not present in the update" do
          before { assign_webhook_status(nil) }

          it { expect { run_service }.to raise_error(ArgumentError) }

          it_behaves_like "logs an error"
        end

        context "when status is present in the update" do
          context "when the payment is not found" do
            before { webhook_resource["payment_id"] = "foo" }

            it { expect { run_service }.to raise_error(ArgumentError) }

            it_behaves_like "logs an error"
          end

          context "when the payment is found" do
            context "when the payment status has not changed" do
              let(:prior_payment_status) { Payment::STATUS_SUBMITTED }

              it { expect { run_service }.not_to change(wcr_payment, :govpay_payment_status) }

              it "writes a warning to the Rails log" do
                run_service

                expect(Rails.logger).to have_received(:warn)
              end
            end

            context "when the payment status has changed" do

              include_examples "Govpay webhook status transitions"

              # unfinished statuses
              it_behaves_like "valid and invalid transitions", Payment::STATUS_CREATED, %w[started submitted success failed cancelled error], %w[]
              it_behaves_like "valid and invalid transitions", "started", %w[submitted success failed cancelled error], %w[created]
              it_behaves_like "valid and invalid transitions", Payment::STATUS_SUBMITTED, %w[success failed cancelled error], %w[started]

              # finished statuses
              it_behaves_like "no valid transitions", Payment::STATUS_SUCCESS
              it_behaves_like "no valid transitions", Payment::STATUS_FAILED
              it_behaves_like "no valid transitions", Payment::STATUS_CANCELLED
              it_behaves_like "no valid transitions", "error"
            end
          end
        end
      end
    end

    # used by shared examples - different for payment vs refund webhooks
    def assign_webhook_status(status)
      webhook_body["resource"]["state"]["status"] = status
    end
  end
end
