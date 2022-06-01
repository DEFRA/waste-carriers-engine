# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "service_provided_form") }

    describe "#workflow_state" do
      context ":service_provided_form state transitions" do
        context "on next" do
          context "when waste is their main service" do
            subject { build(:new_registration, workflow_state: "service_provided_form", is_main_service: "yes") }

            include_examples "has next transition", next_state: "waste_types_form"
          end

          context "when waste is not their main service" do
            include_examples "has next transition", next_state: "construction_demolition_form"
          end
        end
      end
    end
  end
end
