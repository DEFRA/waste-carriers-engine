# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "bank_transfer_form") }

    describe "#workflow_state" do
      context ":bank_transfer_form state transitions" do
        context "on back" do
          include_examples "has back transition", previous_state: "payment_summary_form"
        end
      end
    end
  end
end
