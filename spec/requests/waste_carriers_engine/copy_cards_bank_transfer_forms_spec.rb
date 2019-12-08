# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CopyCardsBankTransferForms", type: :request do
    describe "GET new_copy_cards_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:order_copy_cards_registration, temp_cards: 3, workflow_state: "copy_cards_bank_transfer_form")
          end

          it "creates a plain new order on the transient registration every time is called" do
            expect(transient_registration.finance_details).to be_nil

            get new_copy_cards_bank_transfer_form_path(transient_registration[:reg_identifier])

            first_finance_details = transient_registration.reload.finance_details
            order = first_finance_details.orders.first
            order_item = order.order_items.first

            expect(first_finance_details.orders.count).to eq(1)
            expect(first_finance_details.balance).to eq(1_500)
            expect(order.order_items.count).to eq(1)
            expect(order_item.type).to eq("COPY_CARDS")
            expect(order_item.amount).to eq(1_500)

            get new_copy_cards_bank_transfer_form_path(transient_registration[:reg_identifier])

            second_finance_details = transient_registration.reload.finance_details

            expect(first_finance_details).to_not eq(second_finance_details)
          end
        end
      end
    end

    describe "POST new_copy_cards_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when an order is in progress" do
          let(:transient_registration) do
            create(
              :order_copy_cards_registration,
              :has_finance_details,
              workflow_state: :copy_cards_bank_transfer_form
            )
          end

          it "deletes the transient object and copy all finance details to the registration and redirects to the completion page" do
            registration = transient_registration.registration

            post_form_with_params(:copy_cards_bank_transfer_form, reg_identifier: transient_registration.reg_identifier)

            finance_details = registration.reload.finance_details
            order = finance_details.orders.first
            order_item = order.order_items.first

            # TODO: Discuss bug with Reload and Let at next dev meeting
            expect(WasteCarriersEngine::TransientRegistration.count).to eq(0)

            expect(finance_details.orders.count).to eq(1)
            expect(finance_details.balance).to eq(500)
            expect(order.order_items.count).to eq(1)
            expect(order_item.type).to eq("COPY_CARDS")
            expect(order_item.amount).to eq(500)

            expect(response).to redirect_to(new_copy_cards_order_completed_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end

    describe "GET back_copy_cards_bank_transfer_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:order_copy_cards_registration, workflow_state: :copy_cards_bank_transfer_form)
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_copy_cards_bank_transfer_forms_path(transient_registration[:reg_identifier])

              expect(response).to have_http_status(302)
            end

            it "redirects to the payment_summary form" do
              get back_copy_cards_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_copy_cards_payment_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:order_copy_cards_registration, workflow_state: :copy_cards_bank_transfer_form)
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_copy_cards_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_copy_cards_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_copy_cards_payment_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
