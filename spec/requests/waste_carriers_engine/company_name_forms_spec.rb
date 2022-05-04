# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CompanyNameForms", type: :request do
    include_examples "GET flexible form", "company_name_form"

    describe "POST company_name_form_path" do
      include_examples "POST renewal form",
                       "company_name_form",
                       valid_params: { company_name: "WasteCo Ltd" },
                       invalid_params: { company_name: "" },
                       test_attribute: :company_name

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, :has_required_data, tier: "LOWER", workflow_state: "company_name_form")
        end

        include_examples "POST form",
                         "company_name_form",
                         valid_params: { company_name: "WasteCo Ltd" },
                         invalid_params: { company_name: "" }
      end
    end

    describe "GET back_company_name_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   tier: tier,
                   workflow_state: "company_name_form")
          end

          context "when the back action is triggered" do

            shared_examples "redirects to renewal_information or main_people form based on tier" do
              context "when upper tier" do
                let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
                it "returns a 302 response and redirects to the main_people form" do
                  get back_company_name_forms_path(transient_registration[:token])

                  expect(response).to have_http_status(302)
                  expect(response).to redirect_to(new_main_people_form_path(transient_registration[:token]))
                end
              end

              context "when lower tier" do
                let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }
                it "returns a 302 response and redirects to the renewal_information form" do
                  get back_company_name_forms_path(transient_registration[:token])

                  expect(response).to have_http_status(302)
                  expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:token]))
                end
              end
            end

            context "when the business type is localAuthority" do
              before(:each) { transient_registration.update_attributes(business_type: "localAuthority") }

              it_behaves_like "redirects to renewal_information or main_people form based on tier"
            end

            context "when the business type is partnership" do
              before(:each) { transient_registration.update_attributes(business_type: "partnership") }

              it_behaves_like "redirects to renewal_information or main_people form based on tier"
            end

            context "when the business type is soleTrader" do
              before(:each) { transient_registration.update_attributes(business_type: "soleTrader") }

              it_behaves_like "redirects to renewal_information or main_people form based on tier"
            end

            context "when the location is overseas" do
              before(:each) { transient_registration.update_attributes(location: "overseas") }

              it_behaves_like "redirects to renewal_information or main_people form based on tier"
            end

            context "when the business type is limitedCompany" do
              before(:each) { transient_registration.update_attributes(business_type: "limitedCompany") }

              it "returns a 302 response and redirects to the check_registered_company_name form" do
                get back_company_name_forms_path(transient_registration[:token])

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_check_registered_company_name_form_path(transient_registration[:token]))
              end
            end

            context "when the business type is limitedLiabilityPartnership" do
              before(:each) { transient_registration.update_attributes(business_type: "limitedLiabilityPartnership") }

              it "returns a 302 response and redirects to the check_registered_company_name form" do
                get back_company_name_forms_path(transient_registration[:token])

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_check_registered_company_name_form_path(transient_registration[:token]))
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
              get back_company_name_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
