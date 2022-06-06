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

            include_examples "has next transition", next_state: "your_tier_form"

            it "updates the tier of the object to LOWER" do
              expect { subject.next }.to change { subject.tier }.to(WasteCarriersEngine::NewRegistration::LOWER_TIER)
            end
          end

          context "when the result of smart answers is upper-tier" do
            let(:lower_tier) { false }

            include_examples "has next transition", next_state: "your_tier_form"

            it "updates the tier of the object to UPPER" do
              expect { subject.next }.to change { subject.tier }.to(WasteCarriersEngine::NewRegistration::UPPER_TIER)
            end
          end
        end
      end
    end
  end
end
