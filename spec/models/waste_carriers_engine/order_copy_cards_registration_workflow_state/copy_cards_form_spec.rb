# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsRegistration do
    subject { build(:order_copy_cards_registration, workflow_state: "copy_cards_form") }

    describe "#workflow_state" do
      context ":copy_cards_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "copy_cards_payment_form"
        end
      end
    end
  end
end
