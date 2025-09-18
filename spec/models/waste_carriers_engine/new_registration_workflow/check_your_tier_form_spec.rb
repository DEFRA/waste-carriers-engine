# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject(:new_registration) { build(:new_registration, workflow_state: "check_your_tier_form") }

    describe "#workflow_state" do
      context "with :check_your_tier_form state transitions" do
        context "with :next transition" do
          context "when the check your tier answer is unknown" do
            subject(:new_registration) { build(:new_registration, workflow_state: "check_your_tier_form", temp_check_your_tier: "unknown") }

            it_behaves_like "has next transition", next_state: "other_businesses_form"
          end

          context "when the check your tier answer is upper" do
            subject(:new_registration) { build(:new_registration, workflow_state: "check_your_tier_form", temp_check_your_tier: "upper") }

            it_behaves_like "has next transition", next_state: "cbd_type_form"

            it "updates the tier of the object to UPPER" do
              expect { new_registration.next }.to change(new_registration, :tier).to(WasteCarriersEngine::NewRegistration::UPPER_TIER)
            end
          end

          context "when the check your tier answer is lower" do
            subject(:new_registration) { build(:new_registration, workflow_state: "check_your_tier_form", temp_check_your_tier: "lower") }

            it_behaves_like "has next transition", next_state: "company_name_form"

            it "updates the tier of the object to LOWER" do
              expect { new_registration.next }.to change(new_registration, :tier).to(WasteCarriersEngine::NewRegistration::LOWER_TIER)
            end
          end
        end
      end
    end
  end
end
