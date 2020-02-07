# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "EditForms", type: :request do
    describe "GET new_edit_form_path" do
      context "when a user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no matching registration exists" do
          it "redirects to the invalid token error page" do
            get new_edit_form_path("CBDU999999999")

            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when the token doesn't match the format" do
          it "redirects to the invalid token error page" do
            get new_edit_form_path("foo")

            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when a matching registration exists" do
          context "when the given registration is not active" do
            let(:registration) { create(:registration, :has_required_data, :is_pending) }

            it "redirects to the invalid error page" do
              get new_edit_form_path(registration.reg_identifier)

              expect(response).to redirect_to(page_path("invalid"))
            end
          end

          context "when the given registration is active" do
            let(:registration) { create(:registration, :has_required_data, :is_active) }

            it "responds to the GET request with a 200 status code and renders the appropriate template" do
              get new_edit_form_path(registration.reg_identifier)

              expect(response).to render_template("waste_carriers_engine/edit_forms/new")
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

        it "returns a 302 response and redirects to the sign in page" do
          get new_edit_form_path("foo")

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
