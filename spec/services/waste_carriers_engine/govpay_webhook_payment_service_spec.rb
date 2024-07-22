# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayWebhookPaymentService do
    describe ".run" do

      subject(:run_service) { described_class.run(webhook_body) }

      let(:webhook_body) { JSON.parse(file_fixture("govpay/webhook_payment_update_body.json").read) }
      let(:webhook_resource) { webhook_body["resource"] }
      let(:webhook_resource_state) { webhook_resource["state"] }
      let(:govpay_payment_id) { webhook_body["resource"]["payment_id"] }
      let(:registration) { create(:registration, :has_required_data) }
      let(:prior_payment_status) { nil }
      let!(:wcr_payment) do
        create(:payment, :govpay,
               finance_details: registration.finance_details,
               govpay_id: govpay_payment_id,
               govpay_payment_status: prior_payment_status)
      end

      before do
        allow(Airbrake).to receive(:notify)
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:warn)
        allow(Rails.logger).to receive(:error)
      end

      shared_examples "logs an error" do
        it "notifies Airbrake" do
          run_service

          expect(Airbrake).to have_received(:notify)
        rescue ArgumentError
          # expected exception
        end

        it "writes an error to the Rails log" do
          run_service

          expect(Rails.logger).to have_received(:error)
        rescue ArgumentError
          # expected exception
        end
      end

      shared_examples "does not log an error" do
        it "does not notify Airbrake" do
          run_service

          expect(Airbrake).not_to have_received(:notify)
        end
      end

      context "when the update is not for a payment" do
        before { webhook_body["resource_type"] = "refund" }

        it { expect { run_service }.to raise_error(ArgumentError) }

        it_behaves_like "logs an error"
      end

      context "when the update is for a payment" do
        context "when status is not present in the update" do
          before { webhook_resource_state["status"] = nil }

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
              let(:prior_payment_status) { "submitted" }

              it { expect { run_service }.not_to change(wcr_payment, :govpay_payment_status) }

              it "writes a warning to the Rails log" do
                run_service

                expect(Rails.logger).to have_received(:warn)
              end
            end

            context "when the payment status has changed" do

              shared_examples "a valid transition" do |old_status, new_status|
                let(:prior_payment_status) { old_status }

                before { webhook_resource_state["status"] = new_status }

                it "updates the status from #{old_status} to #{new_status}" do
                  expect { run_service }.to change { wcr_payment.reload.govpay_payment_status }.to(new_status)
                end

                it "does not log an error" do
                  run_service
                  expect(Airbrake).not_to have_received(:notify)
                end

                it "writes an info message to the Rails log" do
                  run_service

                  expect(Rails.logger).to have_received(:info)
                end
              end

              shared_examples "an invalid transition" do |old_status, new_status|
                before { webhook_resource_state["status"] = new_status }

                let(:prior_payment_status) { old_status }

                it "does not update the status from #{old_status} to #{new_status}" do
                  expect { run_service }.not_to change { wcr_payment.reload.govpay_payment_status }
                rescue GovpayWebhookPaymentService::InvalidGovpayStatusTransition
                  # expected exception
                end

                it "logs an error when attempting to update status from #{old_status} to #{new_status}" do
                  run_service

                  expect(Airbrake).to have_received(:notify)
                rescue GovpayWebhookPaymentService::InvalidGovpayStatusTransition
                  # expected exception
                end
              end

              shared_examples "valid and invalid transitions" do |old_status, valid_statuses, invalid_statuses|
                valid_statuses.each do |new_status|
                  it_behaves_like "a valid transition", old_status, new_status
                end

                invalid_statuses.each do |new_status|
                  it_behaves_like "an invalid transition", old_status, new_status
                end
              end

              shared_examples "no valid transitions" do |new_status|
                it_behaves_like "valid and invalid transitions", new_status, %w[], %w[created started submitted success failed cancelled error] - [new_status]
              end

              # unfinished statuses
              it_behaves_like "valid and invalid transitions", "created", %w[started submitted success failed cancelled error], %w[]
              it_behaves_like "valid and invalid transitions", "started", %w[submitted success failed cancelled error], %w[created]
              it_behaves_like "valid and invalid transitions", "submitted", %w[success failed cancelled error], %w[started]

              # finished statuses
              it_behaves_like "no valid transitions", "success"
              it_behaves_like "no valid transitions", "failed"
              it_behaves_like "no valid transitions", "cancelled"
              it_behaves_like "no valid transitions", "error"
            end
          end
        end
      end
    end
  end
end
