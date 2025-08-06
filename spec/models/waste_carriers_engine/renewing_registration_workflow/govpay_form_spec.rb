# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    subject(:renewing_registration) do
      build(:renewing_registration,
            :has_required_data,
            :has_conviction_search_result,
            :has_key_people,
            :has_paid_balance,
            workflow_state: "govpay_form")
    end

    describe "#workflow_state" do
      context "with :govpay_form state transitions" do
        context "with :next transition" do
          context "when a conviction check is not required" do
            before do
              allow(renewing_registration).to receive(:conviction_check_required?).and_return(false)
            end

            context "when there is no pending Govpay payment" do
              before do
                allow(Notifications::Client).to receive(:new)
                allow(renewing_registration).to receive(:pending_online_payment?).and_return(false)
              end

              it_behaves_like "has next transition", next_state: "renewal_complete_form"

              it "does not send a confirmation email after the 'next' event" do
                renewing_registration.next!

                expect(Notifications::Client).not_to have_received(:new)
              end
            end

            context "when there is a pending Govpay payment" do
              before do
                allow(Notify::RenewalPendingOnlinePaymentEmailService).to receive(:run)
                allow(renewing_registration).to receive(:pending_online_payment?).and_return(true)
              end

              it_behaves_like "has next transition", next_state: "renewal_received_pending_govpay_payment_form"

              it "sends a confirmation email after the 'next' event" do
                renewing_registration.next!

                expect(Notify::RenewalPendingOnlinePaymentEmailService)
                  .to have_received(:run)
                  .with(registration: renewing_registration)
                  .once
              end
            end
          end

          context "when a conviction check is required" do
            before do
              allow(Notify::RenewalPendingChecksEmailService).to receive(:run)
              allow(renewing_registration).to receive(:conviction_check_required?).and_return(true)
            end

            it_behaves_like "has next transition", next_state: "renewal_received_pending_conviction_form"

            it "sends a confirmation email after the 'next' event" do
              renewing_registration.next!

              expect(Notify::RenewalPendingChecksEmailService)
                .to have_received(:run)
                .with(registration: renewing_registration)
                .once
            end
          end
        end
      end
    end
  end
end
