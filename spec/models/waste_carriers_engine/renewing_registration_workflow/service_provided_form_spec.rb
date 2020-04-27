# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            is_main_service: is_main_service,
            workflow_state: "service_provided_form")
    end
    let(:is_main_service) {}

    describe "#workflow_state" do
      context ":service_provided_form state transitions" do
        context "on next" do
          context "when the business only carries waste it produces" do
            let(:is_main_service) { "no" }

            include_examples "has next transition", next_state: "construction_demolition_form"
          end

          context "when the business carries waste produced by others" do
            let(:is_main_service) { "yes" }

            include_examples "has next transition", next_state: "waste_types_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "other_businesses_form"
        end
      end
    end
  end
end
