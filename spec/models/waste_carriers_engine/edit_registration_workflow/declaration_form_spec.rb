# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration do
    subject { build(:edit_registration, workflow_state: "declaration_form") }

    describe "#workflow_state" do
      context ":declaration_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "edit_complete_form"

          context "when the registration has changed business type" do
            before { subject.registration_type = "carrier_dealer" }

            include_examples "has next transition", next_state: "edit_payment_summary_form"
          end
        end
      end
    end
  end
end
