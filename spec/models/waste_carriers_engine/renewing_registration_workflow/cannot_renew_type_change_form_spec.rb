# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject(:renewing_registration) { build(:renewing_registration, :has_required_data, workflow_state: "cannot_renew_type_change_form") }

    describe "#workflow_state" do
      context "with :cannot_renew_type_change_form state transitions" do
        context "with :next transition" do
          it "does not respond to the 'next' event" do
            expect(renewing_registration).not_to allow_event :next
          end
        end
      end
    end
  end
end
