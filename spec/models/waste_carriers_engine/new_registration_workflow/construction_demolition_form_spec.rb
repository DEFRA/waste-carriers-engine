# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "construction_demolition_form") }

    describe "#workflow_state" do
      context ":construction_demolition_form state transitions" do
        context "on next" do
          let(:smart_answer_checker_service) { double(:smart_answer_checker_service, lower_tier?: lower_tier) }

          before do
            allow(SmartAnswersCheckerService).to receive(:new).and_return(smart_answer_checker_service)
          end

          context "when the result of smart answers is lower-tier" do
            let(:lower_tier) { true }

            # TODO: Fix me when implement lower-tier journey
            include_examples "has next transition", next_state: "cannot_renew_lower_tier_form"
          end

          context "when the result of smart answers is upper-tier" do
            let(:lower_tier) { false }

            include_examples "has next transition", next_state: "cbd_type_form"
          end
        end

        context "on back" do
          context "when the company only carries its own waste" do
            subject { build(:new_registration, workflow_state: "construction_demolition_form", other_businesses: "no") }

            include_examples "has back transition", previous_state: "other_businesses_form"
          end

          include_examples "has back transition", previous_state: "service_provided_form"
        end
      end
    end
  end
end
