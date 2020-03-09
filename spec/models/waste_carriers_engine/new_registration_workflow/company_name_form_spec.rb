# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "company_name_form") }

    describe "#workflow_state" do
      context ":company_name_form state transitions" do
        context "on next" do
          context "when the business is based overseas" do
            subject { build(:new_registration, workflow_state: "company_name_form", location: "overseas") }

            include_examples "has next transition", next_state: "company_address_manual_form"
          end

          include_examples "has next transition", next_state: "company_postcode_form"
        end

        context "on back" do
          context "when the business does not requires a registration number and the registration is upper tier" do
            subject { build(:new_registration, :upper, workflow_state: "company_name_form", location: "overseas") }

            include_examples "has back transition", previous_state: "cbd_type_form"
          end

          context "when the registration is lower tier" do
            subject { build(:new_registration, :lower, workflow_state: "company_name_form") }

            include_examples "has back transition", previous_state: "waste_types_form"

            context "when the waste is the company's main service" do
              subject { build(:new_registration, :lower, workflow_state: "company_name_form", is_main_service: "yes") }

              include_examples "has back transition", previous_state: "construction_demolition_form"
            end
          end

          context "when the registration's company is a charity" do
            subject { build(:new_registration, workflow_state: "company_name_form", business_type: "charity") }

            include_examples "has back transition", previous_state: "business_type_form"
          end

          include_examples "has back transition", previous_state: "registration_number_form"
        end
      end
    end
  end
end
