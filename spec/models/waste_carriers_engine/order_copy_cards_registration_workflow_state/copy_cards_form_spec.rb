# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsRegistration do
    subject(:order_copy_cards_registration) { build(:order_copy_cards_registration) }

    describe "#workflow_state" do
      context ":copy_cards_form state transitions" do
        context "on next" do
          it "can transition from a :copy_cards_form state to a :copy_cards_payment_form" do
            order_copy_cards_registration.workflow_state = :copy_cards_form

            order_copy_cards_registration.next

            expect(order_copy_cards_registration.workflow_state).to eq("copy_cards_payment_form")
          end
        end
      end
    end
  end
end
