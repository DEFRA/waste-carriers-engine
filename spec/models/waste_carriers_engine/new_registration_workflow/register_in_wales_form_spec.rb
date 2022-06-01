# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "register_in_wales_form") }

    describe "#workflow_state" do
      context ":register_in_wales_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "business_type_form"
        end
      end
    end
  end
end
