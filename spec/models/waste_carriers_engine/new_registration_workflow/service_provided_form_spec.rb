# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "service_provided_form") }

    describe "#workflow_state" do
      context "with :service_provided_form state transitions" do
        context "with :next transition" do
          context "when waste is their main service" do
            subject { build(:new_registration, workflow_state: "service_provided_form", is_main_service: "yes") }

            it_behaves_like "has next transition", next_state: "waste_types_form"
          end

          context "when waste is not their main service" do
            it_behaves_like "has next transition", next_state: "construction_demolition_form"
          end
        end
      end
    end
  end
end
