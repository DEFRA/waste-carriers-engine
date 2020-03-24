# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "your_tier_form") }

    describe "#workflow_state" do
      context ":your_tier_form state transitions" do
        context "on next" do
          context "when the registration is a lower tier registration" do
            subject { build(:new_registration, :lower, workflow_state: "your_tier_form") }

            include_examples "has next transition", next_state: "company_name_form"
          end

          context "when the registration is an upper tier registration" do
            subject { build(:new_registration, :upper, workflow_state: "your_tier_form") }

            include_examples "has next transition", next_state: "cbd_type_form"
          end
        end

        context "on back" do
          context "when the registration is lower tier" do
            subject { build(:new_registration, :lower, workflow_state: "your_tier_form") }

            context "when the waste is the main service" do
              subject { build(:new_registration, :lower, workflow_state: "your_tier_form", is_main_service: "yes") }

              include_examples "has back transition", previous_state: "waste_types_form"
            end

            context "when the company only carries own waste" do
              subject { build(:new_registration, :lower, workflow_state: "your_tier_form", other_businesses: "no") }

              include_examples "has back transition", previous_state: "construction_demolition_form"
            end

            include_examples "has back transition", previous_state: "construction_demolition_form"
          end

          context "when the company deals with more than amf waste" do
            subject { build(:new_registration, workflow_state: "your_tier_form", only_amf: "no") }

            include_examples "has back transition", previous_state: "waste_types_form"
          end

          context "when the registration's company is a charity" do
            subject { build(:new_registration, workflow_state: "your_tier_form", business_type: "charity") }

            include_examples "has back transition", previous_state: "business_type_form"
          end

          include_examples "has back transition", previous_state: "construction_demolition_form"
        end
      end
    end
  end
end
