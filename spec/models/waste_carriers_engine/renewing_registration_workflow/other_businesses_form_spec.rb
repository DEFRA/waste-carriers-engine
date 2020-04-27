# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            other_businesses: other_businesses,
            workflow_state: "other_businesses_form")
    end
    let(:other_businesses) {}

    describe "#workflow_state" do
      context ":other_businesses_form state transitions" do
        context "on next" do
          context "when the business does not carry waste for other businesses or households" do
            let(:other_businesses) { "no" }

            include_examples "has next transition", next_state: "construction_demolition_form"
          end

          context "when the business does carry waste for other businesses or households" do
            let(:other_businesses) { "yes" }

            include_examples "has next transition", next_state: "service_provided_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "tier_check_form"
        end
      end
    end
  end
end
