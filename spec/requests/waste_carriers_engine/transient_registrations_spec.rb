# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "TransientRegistration", type: :request do
    describe "GET delete_transient_registration_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          it "deletes the transient registration, returns a 302 status and redirects to the registration page" do
            transient_registration = create(:renewing_registration, :has_required_data)
            expected_count = TransientRegistration.count - 1
            redirect_path = Rails.application.routes.url_helpers.registration_path(
              reg_identifier: transient_registration.reg_identifier
            )

            get delete_transient_registration_path(transient_registration[:token])

            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(redirect_path)
            expect(TransientRegistration.count).to eq(expected_count)
          end
        end
      end

      context "when a valid user is not signed in" do
        it "returns a 302 status and redirects to the login page" do
          get delete_transient_registration_path("foo")

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to("/users/sign_in")
        end
      end
    end

    describe "GET go_back_forms_path" do
      context "when a valid transient registration exists" do
        let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
        let(:workflow_state) { "company_name_form" }
        let(:workflow_history) { %w[some_form check_registered_company_name_form] }
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 workflow_state: workflow_state,
                 workflow_history: workflow_history)
        end

        it "returns a 302 response" do
          get go_back_forms_path(transient_registration[:token])

          expect(response).to have_http_status(:found)
        end

        it "redirects to the previous form in the workflow_history" do
          get go_back_forms_path(transient_registration[:token])

          expect(response).to redirect_to(new_check_registered_company_name_form_path(transient_registration[:token]))
        end

        context "when the transient registration has a partially invalid workflow history" do
          let(:workflow_history) { %w[check_registered_company_name_form not_a_valid_state] }

          it "redirects to the form for the most recent valid state" do
            get go_back_forms_path(transient_registration[:token])

            expect(response).to redirect_to(new_check_registered_company_name_form_path(transient_registration[:token]))
          end
        end

        context "when the transient registration has a fully invalid workflow history" do
          let(:workflow_history) do
            [
              "",
              "not_a_valid_state"
            ]
          end

          it "redirects to the default form" do
            get go_back_forms_path(transient_registration[:token])

            expect(response).to redirect_to(new_start_form_path(token: transient_registration[:token]))
          end
        end

        context "when the transient registration has no workflow history" do
          let(:workflow_history) { [] }

          it "redirects to the default form" do
            get go_back_forms_path(transient_registration[:token])

            expect(response).to redirect_to(new_start_form_path(token: transient_registration[:token]))
          end
        end
      end
    end
  end
end
