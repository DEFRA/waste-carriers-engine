# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "other_businesses_form") }

    describe "#workflow_state" do
      context ":other_businesses_form state transitions" do
        context "on next" do
          context "when they only carries their own waste" do
            subject { build(:new_registration, workflow_state: "other_businesses_form", other_businesses: "no") }

            include_examples "has next transition", next_state: "construction_demolition_form"
          end

          context "when they carries other's waste too" do
            include_examples "has next transition", next_state: "service_provided_form"
          end
        end
      end
    end
  end
end
