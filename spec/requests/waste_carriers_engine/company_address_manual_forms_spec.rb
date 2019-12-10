# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CompanyAddressManualForms", type: :request do
    include_examples "GET flexible form", "company_address_manual_form"

    describe "POST company_address_manual_forms_path" do
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
                   workflow_state: "company_address_manual_form")
          end

          context "when valid params are submitted" do
            let(:valid_params) do
              {
                company_address: {
                  house_number: "42",
                  address_line_1: "Foo Terrace",
                  town_city: "Barton"
                }
              }
            end

            it "updates the transient registration" do
              post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
              expect(transient_registration.reload.registered_address.house_number).to eq("42")
            end

            it "returns a 302 response" do
              post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
              expect(response).to have_http_status(302)
            end

            it "redirects to the main_people form" do
              post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
              expect(response).to redirect_to(new_main_people_form_path(transient_registration.token))
            end

            context "when the transient registration already has addresses" do
              let(:transient_registration) do
                create(:renewing_registration,
                       :has_required_data,
                       :has_addresses,
                       account_email: user.email,
                       workflow_state: "company_address_manual_form")
              end

              it "should have have the same number of addresses before and after submitting" do
                number_of_addresses = transient_registration.addresses.count
                post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
                expect(transient_registration.reload.addresses.count).to eq(number_of_addresses)
              end

              it "removes the old registered address" do
                old_registered_address = transient_registration.registered_address
                post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
                expect(transient_registration.reload.registered_address).to_not eq(old_registered_address)
              end

              it "adds the new registered address" do
                post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
                expect(transient_registration.reload.registered_address.address_line_1).to eq("Foo Terrace")
              end

              it "does not modify the existing contact address" do
                old_contact_address = transient_registration.contact_address
                post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
                expect(transient_registration.reload.contact_address).to eq(old_contact_address)
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

          let(:valid_params) do
            {
              company_address: {
                house_number: "42",
                address_line_1: "Foo Terrace",
                town_city: "Barton"
              }
            }
          end

          it "does not update the transient registration" do
            post company_address_forms_path(transient_registration.token), company_address_form: valid_params
            expect(transient_registration.reload.addresses.count).to eq(0)
          end

          it "returns a 302 response" do
            post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            post company_address_manual_forms_path(transient_registration.token), company_address_manual_form: valid_params
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration.token))
          end
        end
      end
    end

    describe "GET back_company_address_manual_forms_path" do
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
                   workflow_state: "company_address_manual_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_company_address_manual_forms_path(transient_registration.token)
              expect(response).to have_http_status(302)
            end

            context "when the location is 'overseas'" do
              before(:each) { transient_registration.update_attributes(location: "overseas") }

              it "redirects to the company_name form" do
                get back_company_address_manual_forms_path(transient_registration.token)
                expect(response).to redirect_to(new_company_name_form_path(transient_registration.token))
              end
            end

            context "when the location is not 'overseas'" do
              before(:each) { transient_registration.update_attributes(location: "england") }

              it "redirects to the company_postcode form" do
                get back_company_address_manual_forms_path(transient_registration.token)
                expect(response).to redirect_to(new_company_postcode_form_path(transient_registration.token))
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
              get back_company_address_manual_forms_path(transient_registration.token)
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_company_address_manual_forms_path(transient_registration.token)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
