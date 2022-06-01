# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "cbd_type_form") }

    describe "#workflow_state" do
      context ":cbd_type_form state transitions" do
        context "on next" do
          context "when a company registration number is required" do
            subject { build(:new_registration, workflow_state: "cbd_type_form", business_type: "limitedCompany") }

            include_examples "has next transition", next_state: "registration_number_form"
          end

          include_examples "has next transition", next_state: "main_people_form"
        end
      end
    end
  end
end
