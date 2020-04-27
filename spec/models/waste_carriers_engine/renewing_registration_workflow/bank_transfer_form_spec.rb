# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            :has_unpaid_balance,
            workflow_state: "bank_transfer_form")
    end

    describe "#workflow_state" do
      context ":bank_transfer_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "renewal_received_form"

          it "sends a confirmation email after the 'next' event" do
            expect { subject.next! }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "payment_summary_form"
        end
      end
    end
  end
end
