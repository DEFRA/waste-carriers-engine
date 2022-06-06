# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "location_form") }

    describe "#workflow_state" do
      context ":location_form state transitions" do
        context "on next" do
          subject { build(:new_registration, workflow_state: "location_form", location: location) }

          context "when the location is northern_ireland" do
            let(:location) { "northern_ireland" }

            include_examples "has next transition", next_state: "register_in_northern_ireland_form"
          end

          context "when the location is scotland" do
            let(:location) { "scotland" }

            include_examples "has next transition", next_state: "register_in_scotland_form"
          end

          context "when the location is wales" do
            let(:location) { "wales" }

            include_examples "has next transition", next_state: "register_in_wales_form"
          end

          context "when the location is not in the UK" do
            let(:location) { "overseas" }

            include_examples "has next transition", next_state: "check_your_tier_form"
          end

          context "when the location is in england" do
            let(:location) { "england" }

            include_examples "has next transition", next_state: "business_type_form"
          end
        end
      end
    end
  end
end
