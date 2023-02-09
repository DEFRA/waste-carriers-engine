# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CanUseDeregistrationWorkflow do
    subject(:deregistering_registration) do
      build(:deregistering_registration,
            workflow_state: "deregistration_confirmation_form",
            temp_confirm_deregistration: temp_confirm_deregistration)
    end

    describe "#workflow_state" do
      context "with :deregistration_confirmation_form state transitions" do
        context "with :next transition" do

          context "when deregistration is confirmed" do
            let(:temp_confirm_deregistration) { "yes" }

            include_examples "has next transition", next_state: "deregistration_complete_form"
          end

          context "when deregistration is declined" do
            let(:temp_confirm_deregistration) { "no" }

            include_examples "has next transition", next_state: "start_form"
          end
        end
      end
    end
  end
end
