# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "payment_summary_form") }

    describe "#workflow_state" do
      context ":payment_summary_form state transitions" do
        context "on next" do
          context "when the user choose to pay by card" do
            subject { build(:new_registration, workflow_state: "payment_summary_form", temp_payment_method: "card") }

            include_examples "has next transition", next_state: "worldpay_form"
          end

          include_examples "has next transition", next_state: "confirm_bank_transfer_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "receipt_email_form"
        end
      end
    end
  end
end
