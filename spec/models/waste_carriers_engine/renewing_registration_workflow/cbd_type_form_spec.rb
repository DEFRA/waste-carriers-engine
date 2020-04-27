# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "cbd_type_form")
    end

    describe "#workflow_state" do
      context ":cbd_type_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "renewal_information_form"
        end

        context "on back" do
          context "when temp_tier_check is no" do
            before { subject.temp_tier_check = "no" }

            include_examples "has back transition", previous_state: "tier_check_form"
          end

          context "when temp_tier_check is yes" do
            before { subject.temp_tier_check = "yes" }

            context "when the business doesn't carry waste for other businesses or households" do
              before { subject.other_businesses = "no" }

              include_examples "has back transition", previous_state: "construction_demolition_form"
            end

            context "when the business carries waste produced by its customers" do
              before { subject.is_main_service = "yes" }

              include_examples "has back transition", previous_state: "waste_types_form"
            end

            context "when the business carries carries waste for other businesses but produces that waste" do
              before do
                subject.other_businesses = "yes"
                subject.is_main_service = "no"
              end

              include_examples "has back transition", previous_state: "construction_demolition_form"
            end
          end
        end
      end
    end
  end
end
