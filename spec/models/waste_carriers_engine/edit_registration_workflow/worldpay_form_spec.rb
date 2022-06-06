# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration do
    subject { build(:edit_registration, workflow_state: "worldpay_form") }

    describe "#workflow_state" do
      context ":worldpay_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "edit_complete_form"
        end
      end
    end
  end
end
