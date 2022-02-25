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
          context "when the business does not require a registration number and the registration is upper tier" do
            subject { build(:new_registration, :upper, workflow_state: "company_name_form", location: "overseas") }

            include_examples "has back transition", previous_state: "cbd_type_form"
          end

          context "when the registration is lower tier" do
            subject { build(:new_registration, :lower, workflow_state: "company_name_form") }

            context "when the check your tier answer is lower" do
              subject { build(:new_registration, :lower, workflow_state: "company_name_form", temp_check_your_tier: "lower") }

              include_examples "has back transition", previous_state: "check_your_tier_form"
            end

            include_examples "has back transition", previous_state: "your_tier_form"
          end

          context "When the registration requires a company number" do
            subject { build(:new_registration, workflow_state: "company_name_form", business_type: "limitedCompany") }

            include_examples "has back transition", previous_state: "check_registered_company_name_form"
          end
        end
      end
    end
  end
end
