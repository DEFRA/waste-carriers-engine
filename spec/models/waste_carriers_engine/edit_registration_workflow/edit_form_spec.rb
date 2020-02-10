# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration do
    subject(:edit_registration) { build(:edit_registration) }

    describe "#workflow_state" do
      context ":edit_form state transitions" do
        context "on next" do
          it "can transition from a :edit_form state to a :declaration_form" do
            edit_registration.workflow_state = :edit_form

            edit_registration.next

            expect(edit_registration.workflow_state).to eq("declaration_form")
          end
        end
      end
    end
  end
end
