# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CannotRenewCompanyNoChangeForms", type: :request do
    include_examples "GET flexible form", "cannot_renew_company_no_change_form"

    describe "GET back_cannot_renew_company_no_change_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "cannot_renew_company_no_change_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_cannot_renew_company_no_change_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the registration_number form" do
              get back_cannot_renew_company_no_change_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_cannot_renew_company_no_change_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_cannot_renew_company_no_change_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
