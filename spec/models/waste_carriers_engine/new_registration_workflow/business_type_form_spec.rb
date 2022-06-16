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

            include_examples "has next transition", next_state: "your_tier_form"

            it "updates the tier of the object to LOWER" do
              expect { subject.next }.to change { subject.tier }.to(WasteCarriersEngine::NewRegistration::LOWER_TIER)
            end
          end

          include_examples "has next transition", next_state: "check_your_tier_form"
        end
      end
    end
  end
end
