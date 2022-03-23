# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "check_registered_company_name_form") }

    describe "#workflow_state" do
      context ":check_registered_company_name_form state transitions" do
        context "on next" do
          context "when the user confirms their company house details are correct" do
            subject { build(:new_registration, workflow_state: "check_registered_company_name_form", temp_use_registered_company_details: "yes") }

            include_examples "has next transition", next_state: "company_name_form"
          end

          context "when the user confirms their company house details are wrong" do
            subject { build(:new_registration, workflow_state: "check_registered_company_name_form", temp_use_registered_company_details: "no") }

            include_examples "has next transition", next_state: "incorrect_company_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "registration_number_form"
        end
      end
    end
  end
end
