# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "construction_demolition_form")
    end

    describe "#workflow_state" do
      context ":construction_demolition_form state transitions" do
        context "on next" do
          context "when the registration should change to lower tier" do
            before do
              subject.other_businesses = "yes"
              subject.is_main_service = "yes"
              subject.only_amf = "yes"
            end

            include_examples "has next transition", next_state: "cannot_renew_lower_tier_form"
          end

          context "when the registration should stay upper tier" do
            before do
              subject.other_businesses = "yes"
              subject.is_main_service = "yes"
              subject.only_amf = "no"
            end

            include_examples "has next transition", next_state: "cbd_type_form"
          end
        end

        context "on back" do
          context "when the business does not carry waste for other businesses or households" do
            before { subject.other_businesses = "no" }

            include_examples "has back transition", previous_state: "other_businesses_form"
          end

          context "when the business does carry waste for other businesses or households" do
            before { subject.other_businesses = "yes" }

            include_examples "has back transition", previous_state: "service_provided_form"
          end
        end
      end
    end
  end
end
