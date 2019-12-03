# frozen_string_literal: true

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsRegistration do
    subject(:order_copy_cards_registration) { build(:order_copy_cards_registration) }

    describe "#workflow_state" do
      context ":copy_cards_payment_form state transitions" do
        context "on next" do
          context "when the method is paying by card" do
            it "can transition from :copy_cards_payment_form to :worldpay_form" do
              order_copy_cards_registration.temp_payment_method = "card"
              order_copy_cards_registration.workflow_state = :copy_cards_payment_form

              order_copy_cards_registration.next

              expect(order_copy_cards_registration.workflow_state).to eq("worldpay_form")
            end
          end

          context "when the method is not paying by card" do
            it "can transition from :copy_cards_payment_form to :copy_cards_bank_transfer_form" do
              order_copy_cards_registration.temp_payment_method = "foo"
              order_copy_cards_registration.workflow_state = :copy_cards_payment_form

              order_copy_cards_registration.next

              expect(order_copy_cards_registration.workflow_state).to eq("copy_cards_bank_transfer_form")
            end
          end
        end

        context "on back" do
          it "can transition from a :copy_cards_payment_form state to a :copy_cards_form" do
            order_copy_cards_registration.workflow_state = :copy_cards_payment_form

            order_copy_cards_registration.back

            expect(order_copy_cards_registration.workflow_state).to eq("copy_cards_form")
          end
        end
      end
    end
  end
end
