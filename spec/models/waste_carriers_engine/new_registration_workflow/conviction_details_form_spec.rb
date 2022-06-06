# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "conviction_details_form") }

    describe "#workflow_state" do
      context ":conviction_details_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "contact_name_form"
        end
      end
    end
  end
end
