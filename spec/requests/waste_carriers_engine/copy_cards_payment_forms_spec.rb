# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CopyCardsPaymentForms", type: :request do
    describe "GET new_copy_cards_payment_form_path" do
      context "when a user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no matching registration exists" do
          it "redirects to the invalid token error page" do
            get new_copy_cards_payment_form_path("CBDU999999999")
            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when a matching registration exists" do
          let(:order_copy_cards_registration) { create(:order_copy_cards_registration, workflow_state: "copy_cards_payment_form") }

          it "renders the appropriate template and responds with a 200 status code" do
            get new_copy_cards_payment_form_path(order_copy_cards_registration.token)

            expect(response).to render_template("waste_carriers_engine/copy_cards_payment_forms/new")
            expect(response.code).to eq("200")
          end
        end
      end

      context "when a user is not signed in" do
        before(:each) do
          user = create(:user)
          sign_out(user)
        end

        it "returns a 302 response" do
          get new_copy_cards_payment_form_path("foo")
          expect(response).to have_http_status(302)
        end

        it "redirects to the sign in page" do
          get new_copy_cards_payment_form_path("foo")
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "POST copy_cards_payment_forms_path" do
      context "when a user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no matching registration exists" do
          it "does not create a new transient registration and redirects to the invalid page" do
            original_tr_count = OrderCopyCardsRegistration.count

            post copy_cards_payment_forms_path(token: "CBDU222")

            expect(response).to redirect_to(page_path("invalid"))
            expect(OrderCopyCardsRegistration.count).to eq(original_tr_count)
          end
        end

        context "when a matching registration exists" do
          let(:order_copy_cards_registration) { create(:order_copy_cards_registration, workflow_state: "copy_cards_payment_form") }

          context "when valid params are submitted" do
            let(:valid_params) { { temp_payment_method: temp_payment_method } }

            context "when the temp payment method is `card`" do
              let(:temp_payment_method) { "card" }

              it "updates the transient registration with correct data, returns a 302 response and redirects to the worldpay form" do
                post copy_cards_payment_forms_path(token: order_copy_cards_registration.token), copy_cards_payment_form: valid_params

                order_copy_cards_registration.reload

                expect(order_copy_cards_registration.temp_payment_method).to eq("card")
                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_worldpay_form_path(order_copy_cards_registration.token))
              end
            end

            context "when the temp payment method is `bank_transfer`" do
              let(:temp_payment_method) { "bank_transfer" }

              it "updates the transient registration with correct data, returns a 302 response and redirects to the bank transfer form" do
                post copy_cards_payment_forms_path(token: order_copy_cards_registration.token), copy_cards_payment_form: valid_params

                order_copy_cards_registration.reload

                expect(order_copy_cards_registration.temp_payment_method).to eq("bank_transfer")
                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_copy_cards_bank_transfer_form_path(order_copy_cards_registration.token))
              end
            end
          end

          context "when invalid params are submitted" do
            let(:invalid_params) { { temp_payment_method: "foo" } }

            it "returns a 200 response and render the new copy cards form" do
              post copy_cards_payment_forms_path(token: order_copy_cards_registration.token), copy_cards_payment_form: invalid_params

              expect(response).to have_http_status(200)
              expect(response).to render_template("waste_carriers_engine/copy_cards_payment_forms/new")
            end
          end
        end
      end

      context "when a user is not signed in" do
        before(:each) do
          user = create(:user)
          sign_out(user)
        end

        it "returns a 302 response" do
          post copy_cards_payment_forms_path(token: "1234")

          expect(response).to have_http_status(302)
        end

        it "redirects to the sign in page" do
          post copy_cards_payment_forms_path(token: "1234")

          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
