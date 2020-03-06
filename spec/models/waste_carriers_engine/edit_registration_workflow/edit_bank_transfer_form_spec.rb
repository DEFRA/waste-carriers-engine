# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration, type: :model do
    describe "#workflow_state" do
      it_behaves_like "a simple bidirectional transition",
                      previous_state: :edit_payment_summary_form,
                      current_state: :edit_bank_transfer_form,
                      next_state: :edit_complete_form,
                      factory: :edit_registration
    end
  end
end
