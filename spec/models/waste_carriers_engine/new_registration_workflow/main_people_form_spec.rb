# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "main_people_form") }

    describe "#workflow_state" do
      context ":main_people_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "company_name_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "cbd_type_form"
        end
      end
    end
  end
end
