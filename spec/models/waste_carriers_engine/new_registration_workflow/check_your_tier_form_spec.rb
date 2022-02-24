# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "check_your_tier_form") }

    describe "#workflow_state" do
      context ":check_your_tier_form state transitions" do
        context "on next" do
          context "when the check your tier answer is unknown" do
            subject { build(:new_registration, workflow_state: "check_your_tier_form", temp_check_your_tier: "unknown") }

            include_examples "has next transition", next_state: "other_businesses_form"
          end

          context "when the check your tier answer is upper" do
            subject { build(:new_registration, workflow_state: "check_your_tier_form", temp_check_your_tier: "upper") }

            include_examples "has next transition", next_state: "cbd_type_form"

            it "updates the tier of the object to UPPER" do
              expect { subject.next }.to change { subject.tier }.to(WasteCarriersEngine::NewRegistration::UPPER_TIER)
            end
          end

          context "when the check your tier answer is lower" do
            subject { build(:new_registration, workflow_state: "check_your_tier_form", temp_check_your_tier: "lower") }

            include_examples "has next transition", next_state: "business_name_form"

            it "updates the tier of the object to LOWER" do
              expect { subject.next }.to change { subject.tier }.to(WasteCarriersEngine::NewRegistration::LOWER_TIER)
            end
          end
        end

        context "on back" do
          context "if the company is based overseas" do
            subject { build(:new_registration, workflow_state: "check_your_tier_form", location: "overseas") }

            include_examples "has back transition", previous_state: "location_form"
          end

          subject { build(:new_registration, workflow_state: "check_your_tier_form") }

          include_examples "has back transition", previous_state: "business_type_form"
        end
      end
    end
  end
end
