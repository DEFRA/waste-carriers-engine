# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "declaration_form") }

    describe "#workflow_state" do
      context ":declaration_form state transitions" do
        context "on next" do
          include_examples "can transition next to", next_state: "cards_form"
        end

        context "on back" do
          include_examples "can transition back to", previous_state: "check_your_answers_form"
        end
      end
    end
  end
end
