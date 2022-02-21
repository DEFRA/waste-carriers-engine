# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CompanyTradingNameForms", type: :request do
    include_examples "GET flexible form", "company_trading_name_form"

    describe "POST company_trading_name_form_path" do
      include_examples "POST renewal form",
                       "company_trading_name_form",
                       valid_params: { company_trading_name: "WasteCo Ltd" },
                       invalid_params: { company_trading_name: "" },
                       test_attribute: :company_trading_name

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, :has_required_data, workflow_state: "company_trading_name_form")
        end

        include_examples "POST form",
                         "company_trading_name_form",
                         valid_params: { company_trading_name: "WasteCo Ltd" },
                         invalid_params: { company_trading_name: "" }
      end
    end

    describe "GET back_company_trading_name_forms_path" do
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
                   workflow_state: "company_trading_name_form")
          end

          context "when the back action is triggered" do
            context "when the business type is localAuthority" do
              before(:each) { transient_registration.update_attributes(business_type: "localAuthority") }

              it "returns a 302 response and redirects to the renewal_information form" do
                get back_company_trading_name_forms_path(transient_registration[:token])

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is limitedCompany" do
              before(:each) { transient_registration.update_attributes(business_type: "limitedCompany") }

              it "returns a 302 response and redirects to the registration_number form" do
                get back_company_trading_name_forms_path(transient_registration[:token])

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is limitedLiabilityPartnership" do
              before(:each) { transient_registration.update_attributes(business_type: "limitedLiabilityPartnership") }

              it "returns a 302 response and redirects to the registration_number form" do
                get back_company_trading_name_forms_path(transient_registration[:token])

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:token]))
              end
            end

            context "when the location is overseas" do
              before(:each) { transient_registration.update_attributes(location: "overseas") }

              it "returns a 302 response and redirects to the renewal_information form" do
                get back_company_trading_name_forms_path(transient_registration[:token])

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is partnership" do
              before(:each) { transient_registration.update_attributes(business_type: "partnership") }

              it "returns a 302 response and redirects to the renewal_information form" do
                get back_company_trading_name_forms_path(transient_registration[:token])

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is soleTrader" do
              before(:each) { transient_registration.update_attributes(business_type: "soleTrader") }

              it "returns a 302 response and redirects to the renewal_information form" do
                get back_company_trading_name_forms_path(transient_registration[:token])

                expect(response).to have_http_status(302)
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
            it "returns a 302 response and redirects to the correct form for the state" do
              get back_company_trading_name_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
