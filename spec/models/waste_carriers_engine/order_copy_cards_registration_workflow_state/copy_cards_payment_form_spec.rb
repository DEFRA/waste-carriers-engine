# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsRegistration do
    subject { build(:order_copy_cards_registration, workflow_state: "copy_cards_payment_form") }

    describe "#workflow_state" do
      context ":worldpay_form state transitions" do
        context "on next" do
          context "when the method is paying by card" do
            before { subject.temp_payment_method = "card" }

            include_examples "has next transition", next_state: "worldpay_form"
          end

          context "when the method is not paying by card" do
            before { subject.temp_payment_method = "bank_transfer" }

            include_examples "has next transition", next_state: "copy_cards_bank_transfer_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "copy_cards_form"
        end
      end
    end
  end
end
