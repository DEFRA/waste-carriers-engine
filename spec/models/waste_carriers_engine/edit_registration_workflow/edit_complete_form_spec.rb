# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration, type: :model do
    subject(:edit_registration) { build(:edit_registration) }

    describe "#workflow_state" do
      context ":edit_complete_form state transitions" do
        it "does not respond to the 'back' event" do
          edit_registration.workflow_state = :edit_complete_form

          expect(edit_registration).to_not allow_event(:back)
        end

        it "does not respond to the 'next' event" do
          edit_registration.workflow_state = :edit_complete_form

          expect(edit_registration).to_not allow_event(:next)
        end
      end
    end
  end
end
