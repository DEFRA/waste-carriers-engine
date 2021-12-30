# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CheckCompanyForms", type: :request do
    include_examples "GET flexible form", "check_company_form"

    let(:user) { create(:user) }

    before(:each) do
      sign_in(user)
    end

    describe "POST check_company_form_path" do
      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "check_company_form")
        end

        include_examples "POST form",
                         "check_company_form",
                         valid_params: { temp_use_companies_house_details: "yes" },
                         invalid_params: { temp_use_companies_house_details: "" }

        context "when the companies house details will be used" do
          it "redirects to declare_convictions form" do
            post_form_with_params(
              :check_company_form,
              transient_registration.token,
              { temp_use_companies_house_details: "yes" }
            )

            expect(response).to have_http_status(302)

            expect(response).to redirect_to(
              new_declare_convictions_form_path(transient_registration.token)
            )
          end
        end

        context "when the companies house details are not correct" do
          it "redirects to incorrect_company form" do
            post_form_with_params(
              :check_company_form,
              transient_registration.token,
              { temp_use_companies_house_details: "no" }
            )

            expect(response).to have_http_status(302)

            expect(response).to redirect_to(
              new_incorrect_company_form_path(transient_registration.token)
            )
          end
        end

        it "has a link to enter a different number" do
          get new_check_company_form_path(transient_registration.token)

          expect(response.body).to match(
            %r{href="/#{transient_registration.token}/registration-number">Enter a different number}
          )
        end
      end
    end

    describe "GET back_check_company_form_path" do
      context "when a valid user is signed in" do
        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:new_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "check_company_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the company_number form" do
              get back_contact_address_reuse_forms_path(transient_registration.token)

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_check_company_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
