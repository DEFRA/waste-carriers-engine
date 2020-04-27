# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            temp_tier_check: temp_tier_check,
            workflow_state: "tier_check_form")
    end
    let(:temp_tier_check) {}

    describe "#workflow_state" do
      context ":tier_check_form state transitions" do
        context "on next" do
          context "when temp_tier_check is no" do
            let(:temp_tier_check) { "no" }

            include_examples "has next transition", next_state: "cbd_type_form"
          end

          context "when temp_tier_check is yes" do
            let(:temp_tier_check) { "yes" }

            include_examples "has next transition", next_state: "other_businesses_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "business_type_form"

          context "when the business is overseas" do
            before(:each) { subject.location = "overseas" }

            include_examples "has back transition", previous_state: "location_form"
          end
        end
      end
    end
  end
end
