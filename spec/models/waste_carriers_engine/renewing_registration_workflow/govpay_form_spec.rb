# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            :has_conviction_search_result,
            :has_key_people,
            :has_paid_balance,
            workflow_state: "govpay_form")
    end

    describe "#workflow_state" do
      context ":govpay_form state transitions" do
        context "on next" do
          context "when a conviction check is not required" do
            before do
              allow(subject).to receive(:conviction_check_required?).and_return(false)
            end

            context "when there is no pending Govpay payment" do
              before do
                allow(subject).to receive(:pending_online_payment?).and_return(false)
              end

              include_examples "has next transition", next_state: "renewal_complete_form"

              it "does not send a confirmation email after the 'next' event" do
                expect(Notifications::Client).not_to receive(:new)

                subject.next!
              end
            end

            context "when there is a pending Govpay payment" do
              before do
                allow(subject).to receive(:pending_online_payment?).and_return(true)
              end

              include_examples "has next transition", next_state: "renewal_received_pending_govpay_payment_form"

              it "sends a confirmation email after the 'next' event" do
                expect(Notify::RenewalPendingOnlinePaymentEmailService)
                  .to receive(:run)
                  .with(registration: subject)
                  .once

                subject.next!
              end
            end
          end

          context "when a conviction check is required" do
            before do
              allow(subject).to receive(:conviction_check_required?).and_return(true)
            end

            include_examples "has next transition", next_state: "renewal_received_pending_conviction_form"

            it "sends a confirmation email after the 'next' event" do
              expect(Notify::RenewalPendingChecksEmailService)
                .to receive(:run)
                .with(registration: subject)
                .once

              subject.next!
            end
          end
        end
      end
    end
  end
end
