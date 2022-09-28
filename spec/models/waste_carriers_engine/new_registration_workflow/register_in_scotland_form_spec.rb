# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "register_in_scotland_form") }

    describe "#workflow_state" do
      context "with :register_in_scotland_form state transitions" do
        context "with :next transition" do
          include_examples "has next transition", next_state: "business_type_form"
        end
      end
    end
  end
end
