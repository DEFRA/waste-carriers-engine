# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration do
    subject(:edit_registration) { build(:edit_registration) }

    describe "#workflow_state" do
      context ":declaration_form state transitions" do
        context "on next" do
          it "can transition from a :declaration_form state to a :edit_complete_form" do
            edit_registration.workflow_state = :declaration_form

            edit_registration.next

            expect(edit_registration.workflow_state).to eq("edit_complete_form")
          end
        end

        context "on back" do
          it "can transition from a :declaration_form state to a :edit_form" do
            edit_registration.workflow_state = :declaration_form

            edit_registration.back

            expect(edit_registration.workflow_state).to eq("edit_form")
          end
        end
      end
    end
  end
end
