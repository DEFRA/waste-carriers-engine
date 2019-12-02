# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsRegistration, type: :model do
    subject(:order_copy_cards_registration) { build(:order_copy_cards_registration, :has_required_data) }

    describe "workflow_state" do
      context "when a OrderCopyCardsRegistration is created" do
        it "has the state :copy_cards_form" do
          expect(order_copy_cards_registration).to have_state(:copy_cards_form)
        end
      end

      context "transitions" do
        context "on next" do
          it "can transition from a :copy_cards_form state to a :copy_cards_payment_form" do
            order_copy_cards_registration.workflow_state = :copy_cards_form

            order_copy_cards_registration.next

            expect(order_copy_cards_registration.workflow_state).to eq("copy_cards_payment_form")
          end

          context "when the method is paying by card" do
            it "can transition from :copy_cards_payment_form to :worldpay_form" do
              order_copy_cards_registration.temp_payment_method = "card"
              order_copy_cards_registration.workflow_state = :copy_cards_payment_form

              order_copy_cards_registration.next

              expect(order_copy_cards_registration.workflow_state).to eq("worldpay_form")
            end
          end

          context "when the method is not paying by card" do
            it "can transition from :copy_cards_payment_form to :bank_transfer_form" do
              order_copy_cards_registration.temp_payment_method = "foo"
              order_copy_cards_registration.workflow_state = :copy_cards_payment_form

              order_copy_cards_registration.next

              expect(order_copy_cards_registration.workflow_state).to eq("bank_transfer_form")
            end
          end
        end

        context "on back" do
          it "can transition from a :copy_cards_payment_form state to a :copy_cards_form" do
            order_copy_cards_registration.workflow_state = :copy_cards_payment_form

            order_copy_cards_registration.back

            expect(order_copy_cards_registration.workflow_state).to eq("copy_cards_form")
          end

          it "can transition from a :worldpay_form state to a :copy_cards_payment_form" do
            order_copy_cards_registration.workflow_state = :worldpay_form

            order_copy_cards_registration.back

            expect(order_copy_cards_registration.workflow_state).to eq("copy_cards_payment_form")
          end

          it "can transition from a :bank_transfer_form state to a :copy_cards_payment_form" do
            order_copy_cards_registration.workflow_state = :bank_transfer_form

            order_copy_cards_registration.back

            expect(order_copy_cards_registration.workflow_state).to eq("copy_cards_payment_form")
          end
        end
      end
    end

    context "Validations" do
      describe "reg_identifier" do
        context "when a OrderCopyCardsRegistration is created" do
          it "is not valid if the reg_identifier is in the wrong format" do
            order_copy_cards_registration.reg_identifier = "foo"
            expect(order_copy_cards_registration).to_not be_valid
          end

          it "is not valid if no matching registration exists" do
            order_copy_cards_registration.reg_identifier = "CBDU999999"
            expect(order_copy_cards_registration).to_not be_valid
          end

          it "is valid if the reg_identifier is already in use" do
            existing_order_copy_cards_registration = create(:order_copy_cards_registration, :has_required_data)
            order_copy_cards_registration.reg_identifier = existing_order_copy_cards_registration.reg_identifier
            expect(order_copy_cards_registration).to be_valid
          end
        end
      end
    end
  end
end
