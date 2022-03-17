# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "IncorrectCompanyForms", type: :request do
    include_examples "GET flexible form", "incorrect_company_form"

    describe "POST incorrect_company_form_path" do
      let(:transient_registration) do
        create(:new_registration, workflow_state: "incorrect_company_form")
      end

      it "redirects to registeration_number_form" do
        post_form_with_params(:incorrect_company_form, transient_registration.token)

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_registration_number_form_path(transient_registration.token))
      end
    end

    describe "GET back_incorrect_company_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:new_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "incorrect_company_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the check_registered_company_name" do
              get back_incorrect_company_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(check_registered_company_name_forms_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
