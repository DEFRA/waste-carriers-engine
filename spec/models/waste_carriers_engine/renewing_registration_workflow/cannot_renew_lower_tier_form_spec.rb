# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "cannot_renew_lower_tier_form")
    end

    describe "#workflow_state" do
      context ":cannot_renew_lower_tier_form state transitions" do
        context "on next" do
          it "does not respond to the 'next' event" do
            expect(subject).to_not allow_event :next
          end
        end

        context "on back" do
          context "when the tier change is due to the business type" do
            before { subject.business_type = "charity" }

            include_examples "has back transition", previous_state: "business_type_form"
          end

          context "when the tier change is because the business only deals with certain waste types" do
            before do
              subject.other_businesses = "yes"
              subject.is_main_service = "yes"
              subject.only_amf = "yes"
            end

            include_examples "has back transition", previous_state: "waste_types_form"
          end

          context "when the tier change is because the business doesn't deal with construction waste" do
            before do
              subject.other_businesses = "no"
              subject.construction_waste = "no"
            end

            include_examples "has back transition", previous_state: "construction_demolition_form"
          end
        end
      end
    end
  end
end
