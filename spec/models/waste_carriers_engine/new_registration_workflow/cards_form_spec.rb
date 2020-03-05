# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "cards_form") }

    describe "#workflow_state" do
      context ":cards_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "payment_summary_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "declaration_form"
        end
      end
    end
  end
end
