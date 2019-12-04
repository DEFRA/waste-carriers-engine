# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CopyCardsForms", type: :request do
    describe "GET new_copy_cards_form_path" do
      context "when a user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no matching registration exists" do
          it "redirects to the invalid reg_identifier error page" do
            get new_copy_cards_form_path("CBDU999999999")
            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when the reg_identifier doesn't match the format" do
          it "redirects to the invalid reg_identifier error page" do
            get new_copy_cards_form_path("foo")
            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when a matching registration exists" do
          context "when the given registration is not active" do
            let(:registration) { create(:registration, :has_required_data, :is_pending) }

            it "redirects to the page" do
              get new_copy_cards_form_path(registration.reg_identifier)

              expect(response).to redirect_to(page_path("invalid"))
            end
          end

          context "when the given registration is active" do
            let(:registration) { create(:registration, :has_required_data, :is_active) }

            it "renders the appropriate template" do
              get new_copy_cards_form_path(registration.reg_identifier)

              expect(response).to render_template("waste_carriers_engine/copy_cards_forms/new")
            end

            it "responds to the GET request with a 200 status code" do
              get new_copy_cards_form_path(registration.reg_identifier)

              expect(response.code).to eq("200")
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
          get new_copy_cards_form_path("foo")
          expect(response).to have_http_status(302)
        end

        it "redirects to the sign in page" do
          get new_copy_cards_form_path("foo")
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "POST copy_cards_forms_path" do
      context "when a user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no matching registration exists" do
          let(:invalid_params) { { reg_identifier: "CBDU99999" } }

          it "redirects to the invalid reg_identifier error page" do
            post copy_cards_forms_path, copy_cards_form: invalid_params
            expect(response).to redirect_to(page_path("invalid"))
          end

          it "does not create a new transient registration" do
            original_tr_count = OrderCopyCardsRegistration.count
            post copy_cards_forms_path, copy_cards_form: invalid_params
            updated_tr_count = OrderCopyCardsRegistration.count

            expect(original_tr_count).to eq(updated_tr_count)
          end
        end

        context "when the reg_identifier doesn't match the format" do
          let(:invalid_params) { { reg_identifier: "foo" } }

          it "redirects to the invalid reg_identifier error page" do
            post copy_cards_forms_path, copy_cards_form: invalid_params
            expect(response).to redirect_to(page_path("invalid"))
          end

          it "does not create a new transient registration" do
            original_tr_count = OrderCopyCardsRegistration.count
            post copy_cards_forms_path, copy_cards_form: invalid_params
            updated_tr_count = OrderCopyCardsRegistration.count

            expect(original_tr_count).to eq(updated_tr_count)
          end
        end

        context "when a matching registration exists" do
          let(:registration) { create(:registration, :has_required_data, :is_active) }

          context "when valid params are submitted" do
            let(:valid_params) { { reg_identifier: registration.reg_identifier, temp_cards: 3 } }

            it "creates a transient registration with correct data, returns a 302 response and redirects to the copy cards payment form" do
              expected_tr_count = OrderCopyCardsRegistration.count + 1

              post copy_cards_forms_path, copy_cards_form: valid_params

              transient_registration = OrderCopyCardsRegistration.find_by(reg_identifier: registration.reg_identifier)

              expect(expected_tr_count).to eq(OrderCopyCardsRegistration.count)
              expect(transient_registration.temp_cards).to eq(3)
              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_copy_cards_payment_form_path(valid_params[:reg_identifier]))
            end
          end

          context "when invalid params are submitted" do
            let(:invalid_params) { { reg_identifier: registration.reg_identifier, temp_cards: 0 } }

            it "returns a 200 response and render the new copy cards form" do
              post copy_cards_forms_path, copy_cards_form: invalid_params

              expect(response).to have_http_status(200)
              expect(response).to render_template("waste_carriers_engine/copy_cards_forms/new")
            end
          end
        end
      end

      context "when a user is not signed in" do
        let(:registration) { create(:registration, :has_required_data) }
        let(:valid_params) { { reg_identifier: registration[:reg_identifier] } }

        before(:each) do
          user = create(:user)
          sign_out(user)
        end

        it "returns a 302 response" do
          post copy_cards_forms_path, renewal_start_form: valid_params

          expect(response).to have_http_status(302)
        end

        it "redirects to the sign in page" do
          post copy_cards_forms_path, renewal_start_form: valid_params

          expect(response).to redirect_to(new_user_session_path)
        end

        it "does not create a new transient registration" do
          original_tr_count = OrderCopyCardsRegistration.count
          post copy_cards_forms_path, renewal_start_form: valid_params
          updated_tr_count = OrderCopyCardsRegistration.count

          expect(original_tr_count).to eq(updated_tr_count)
        end
      end
    end
  end
end
