# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "payment_summary_form") }

    describe "#workflow_state" do
      context "with :payment_summary_form state transitions" do
        context "with :next transition" do
          context "when the user choose to pay by card" do
            subject { build(:new_registration, workflow_state: "payment_summary_form", temp_payment_method: "card") }

            include_examples "has next transition", next_state: "payment_method_confirmation_form"
          end

          context "when the user choose to pay by bank transfer" do
            subject { build(:new_registration, workflow_state: "payment_summary_form", temp_payment_method: "bank_transfer") }

            include_examples "has next transition", next_state: "payment_method_confirmation_form"
          end
        end
      end
    end
  end
end
