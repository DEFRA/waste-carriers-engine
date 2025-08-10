# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "other_businesses_form") }

    describe "#workflow_state" do
      context "with :other_businesses_form state transitions" do
        context "with :next transition" do
          context "when they only carries their own waste" do
            subject { build(:new_registration, workflow_state: "other_businesses_form", other_businesses: "no") }

            it_behaves_like "has next transition", next_state: "construction_demolition_form"
          end

          context "when they carries other's waste too" do
            it_behaves_like "has next transition", next_state: "service_provided_form"
          end
        end
      end
    end
  end
end
