# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject(:new_registration) { build(:new_registration, workflow_state: "business_type_form") }

    describe "#workflow_state" do
      context "with :business_type_form state transitions" do
        context "with :next transition" do
          context "when the business type is a lower tier specific type" do
            subject(:new_registration) { build(:new_registration, workflow_state: "business_type_form", business_type: "charity") }

            it_behaves_like "has next transition", next_state: "your_tier_form"

            it "updates the tier of the object to LOWER" do
              expect { new_registration.next }.to change(new_registration, :tier).to(WasteCarriersEngine::NewRegistration::LOWER_TIER)
            end
          end

          it_behaves_like "has next transition", next_state: "check_your_tier_form"
        end
      end
    end
  end
end
