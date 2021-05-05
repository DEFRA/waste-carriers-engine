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
            workflow_state: "worldpay_form")
    end

    describe "#workflow_state" do
      context ":worldpay_form state transitions" do
        context "on next" do
          context "when a conviction check is not required" do
            before do
              allow(subject).to receive(:conviction_check_required?).and_return(false)
            end

            context "when there is no pending WorldPay payment" do
              before do
                allow(subject).to receive(:pending_worldpay_payment?).and_return(false)
              end

              include_examples "has next transition", next_state: "renewal_complete_form"

              it "does not send a confirmation email after the 'next' event" do
                # An older incarnation of this spec checked that ActionMailer
                # did not send *any* emails.
                # Here we check to see if the notification service has been invoked,
                # which should tell us if *any* emails have been sent.
                expect(Notifications::Client).not_to receive(:new)

                subject.next!
              end
            end

            context "when there is a pending WorldPay payment" do
              before do
                allow(subject).to receive(:pending_worldpay_payment?).and_return(true)
              end

              include_examples "has next transition", next_state: "renewal_received_pending_worldpay_payment_form"

              it "sends a confirmation email after the 'next' event" do
                expect(Notify::RenewalPendingWorldpayPaymentEmailService)
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

        context "on back" do
          include_examples "has back transition", previous_state: "payment_summary_form"
        end
      end
    end
  end
end
