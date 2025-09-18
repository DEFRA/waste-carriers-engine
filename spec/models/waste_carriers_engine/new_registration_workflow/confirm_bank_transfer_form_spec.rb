# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject(:new_registration) { build(:new_registration, workflow_state: "confirm_bank_transfer_form") }

    describe "#workflow_state" do
      context "with :confirm_bank_transfer_form state transitions" do
        context "with :next transition" do
          it_behaves_like "has next transition", next_state: "registration_received_pending_payment_form"
        end
      end
    end
  end
end
