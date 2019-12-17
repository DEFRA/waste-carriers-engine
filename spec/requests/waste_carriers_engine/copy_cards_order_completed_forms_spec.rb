# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CopyCardsOrderCompletedForm", type: :request do
    describe "GET new_copy_cards_order_completed_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when no transient registration exists" do
          it "redirects to the invalid page" do
            get new_copy_cards_order_completed_form_path("wibblewobblejellyonaplate")

            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(
              :order_copy_cards_registration,
              :has_finance_details,
              workflow_state: "copy_cards_order_completed_form"
            )
          end

          context "when the workflow_state is correct" do
            it "deletes the transient object and copy all finance details to the registration and load the confirmation page" do
              registration = transient_registration.registration

              get new_copy_cards_order_completed_form_path(transient_registration.token)

              finance_details = registration.reload.finance_details
              order = finance_details.orders.first
              order_item = order.order_items.first

              expect(WasteCarriersEngine::TransientRegistration.count).to eq(0)

              expect(finance_details.orders.count).to eq(1)
              expect(finance_details.balance).to eq(500)
              expect(order.order_items.count).to eq(1)
              expect(order_item.type).to eq("COPY_CARDS")
              expect(order_item.amount).to eq(500)
              expect(response).to have_http_status(200)
              expect(response).to render_template("waste_carriers_engine/copy_cards_order_completed_forms/new")
            end
          end
        end
      end
    end
  end
end
