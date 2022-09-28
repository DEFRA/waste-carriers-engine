# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "cannot_renew_type_change_form")
    end

    describe "#workflow_state" do
      context ":cannot_renew_type_change_form state transitions" do
        context "on next" do
          it "does not respond to the 'next' event" do
            expect(subject).not_to allow_event :next
          end
        end
      end
    end
  end
end
