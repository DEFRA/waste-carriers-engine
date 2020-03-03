# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "business_type_form") }

    describe "#workflow_state" do
      context ":business_type_form state transitions" do
        context "on next" do
          context "when the business type is a lower tier specific type" do
            subject { build(:new_registration, workflow_state: "business_type_form", business_type: "charity") }

            # TODO: Fix when implementing lower tier flow
            include_examples "can transition next to", next_state: "cannot_renew_lower_tier_form"
          end

          include_examples "can transition next to", next_state: "other_businesses_form"
        end

        context "on back" do
          subject { build(:new_registration, workflow_state: "business_type_form", location: location) }

          context "when the location is northern_ireland" do
            let(:location) { "northern_ireland" }

            include_examples "can transition back to", previous_state: "register_in_northern_ireland_form"
          end

          context "when the location is scotland" do
            let(:location) { "scotland" }

            include_examples "can transition back to", previous_state: "register_in_scotland_form"
          end

          context "when the location is wales" do
            let(:location) { "wales" }

            include_examples "can transition back to", previous_state: "register_in_wales_form"
          end

          context "when the location is in england" do
            let(:location) { "england" }

            include_examples "can transition back to", previous_state: "location_form"
          end
        end
      end
    end
  end
end
