# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "renewal_start_form")
    end

    describe "#workflow_state" do
      context ":renewal_start_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "location_form"
        end

        context "on back" do
          it "does not respond to the 'back' event" do
            expect(subject).to_not allow_event :back
          end
        end
      end
    end
  end
end
