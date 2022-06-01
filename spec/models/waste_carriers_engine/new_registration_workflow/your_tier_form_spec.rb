# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "your_tier_form", temp_check_your_tier: "unknown") }

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
      end
    end
  end
end
