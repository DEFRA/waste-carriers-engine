# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject(:renewing_registration) do
      build(:renewing_registration,
            :has_required_data,
            :has_unpaid_balance,
            workflow_state: "confirm_bank_transfer_form")
    end

    describe "#workflow_state" do
      context "with :confirm_bank_transfer_form state transitions" do
        context "with :next transition" do
          include_examples "has next transition", next_state: "renewal_received_pending_payment_form"

          it "sends a confirmation email after the 'next' event" do
            expect(Notify::RenewalPendingPaymentEmailService)
              .to receive(:run)
              .with(registration: renewing_registration)
              .once

              renewing_registration.next!
          end
        end
      end
    end
  end
end
