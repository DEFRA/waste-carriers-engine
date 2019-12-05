# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CompanyNameForms", type: :request do
    include_examples "GET flexible form", "company_name_form"

    include_examples "POST form",
                     "company_name_form",
                     valid_params: { company_name: "WasteCo Ltd" },
                     invalid_params: { company_name: "" },
                     test_attribute: :company_name

    describe "GET back_company_name_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "company_name_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_company_name_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            context "when the business type is localAuthority" do
              before(:each) { transient_registration.update_attributes(business_type: "localAuthority") }

              it "redirects to the renewal_information form" do
                get back_company_name_forms_path(transient_registration[:token])
                expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is limitedCompany" do
              before(:each) { transient_registration.update_attributes(business_type: "limitedCompany") }

              it "redirects to the registration_number form" do
                get back_company_name_forms_path(transient_registration[:token])
                expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is limitedLiabilityPartnership" do
              before(:each) { transient_registration.update_attributes(business_type: "limitedLiabilityPartnership") }

              it "redirects to the registration_number form" do
                get back_company_name_forms_path(transient_registration[:token])
                expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:token]))
              end
            end

            context "when the location is overseas" do
              before(:each) { transient_registration.update_attributes(location: "overseas") }

              it "redirects to the renewal_information form" do
                get back_company_name_forms_path(transient_registration[:token])
                expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is partnership" do
              before(:each) { transient_registration.update_attributes(business_type: "partnership") }

              it "redirects to the renewal_information form" do
                get back_company_name_forms_path(transient_registration[:token])
                expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is soleTrader" do
              before(:each) { transient_registration.update_attributes(business_type: "soleTrader") }

              it "redirects to the renewal_information form" do
                get back_company_name_forms_path(transient_registration[:token])
                expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:token]))
              end
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_company_name_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_company_name_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
