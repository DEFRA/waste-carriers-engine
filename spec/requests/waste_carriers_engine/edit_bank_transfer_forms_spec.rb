# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "EditBankTransferForms", type: :request do
    describe "GET new_edit_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:edit_registration, registration_type: "carrier_dealer", workflow_state: "edit_bank_transfer_form")
          end

          it "creates a new order on the transient registration every time it is called" do
            expect(transient_registration.finance_details).to be_nil

            get new_edit_bank_transfer_form_path(transient_registration.token)

            first_finance_details = transient_registration.reload.finance_details
            order = first_finance_details.orders.first
            order_item = order.order_items.first

            expect(first_finance_details.orders.count).to eq(1)
            expect(first_finance_details.balance).to eq(4_000)
            expect(order.order_items.count).to eq(1)
            expect(order_item.type).to eq("EDIT")
            expect(order_item.amount).to eq(4_000)

            get new_edit_bank_transfer_form_path(transient_registration.token)

            second_finance_details = transient_registration.reload.finance_details

            expect(first_finance_details).to_not eq(second_finance_details)
          end
        end
      end
    end

    describe "POST new_edit_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when an order is in progress" do
          let(:transient_registration) do
            create(
              :edit_registration,
              :has_finance_details,
              workflow_state: :edit_bank_transfer_form
            )
          end

          it "redirects to the completion page" do
            post_form_with_params(:edit_bank_transfer_form, transient_registration.token)

            expect(response).to redirect_to(new_edit_complete_form_path(transient_registration.token))
          end
        end
      end
    end
  end
end
