# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CompanyAddressForms", type: :request do
    before do
      stub_address_finder_service(uprn: "340116")
    end

    include_examples "GET flexible form", "company_address_form"

    describe "POST company_address_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "company_address_form")
          end

          context "when valid params are submitted" do
            let(:valid_params) do
              {
                token: transient_registration[:token],
                company_address: {
                  uprn: "340116"
                }
              }
            end

            it "updates the transient registration" do
              post company_address_forms_path(transient_registration.token), company_address_form: valid_params
              expect(transient_registration.reload.company_address.uprn.to_s).to eq("340116")
            end

            it "returns a 302 response" do
              post company_address_forms_path(transient_registration.token), company_address_form: valid_params
              expect(response).to have_http_status(302)
            end

            it "redirects to the main_people form" do
              post company_address_forms_path(transient_registration.token), company_address_form: valid_params
              expect(response).to redirect_to(new_main_people_form_path(transient_registration[:token]))
            end

            context "when the transient registration already has addresses" do
              let(:transient_registration) do
                create(:renewing_registration,
                       :has_required_data,
                       :has_addresses,
                       account_email: user.email,
                       workflow_state: "company_address_form")
              end

              it "should have have the same number of addresses before and after submitting" do
                number_of_addresses = transient_registration.addresses.count

                post company_address_forms_path(transient_registration.token), company_address_form: valid_params

                expect(transient_registration.reload.addresses.count).to eq(number_of_addresses)
              end

              it "updates the old contact address" do
                transient_registration.company_address.update_attributes(uprn: "123456")

                post company_address_forms_path(transient_registration.token), company_address_form: valid_params

                expect(transient_registration.reload.company_address.uprn).to eq(340_116)
              end
            end
          end

          context "when invalid params are submitted" do
            it "returns a 302 response" do
              post company_address_forms_path("foo"), company_address_form: {}
              expect(response).to have_http_status(302)
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          let(:valid_params) do
            {
              token: transient_registration[:token]
            }
          end

          it "does not update the transient registration" do
            post company_address_forms_path(transient_registration.token), company_address_form: valid_params
            expect(transient_registration.reload.addresses.count).to eq(0)
          end

          it "returns a 302 response" do
            post company_address_forms_path(transient_registration.token), company_address_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            post company_address_forms_path(transient_registration.token), company_address_form: valid_params
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
          end
        end
      end
    end

    describe "GET back_company_address_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "company_address_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_company_address_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the company_postcode form" do
              get back_company_address_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_company_postcode_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_company_address_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_company_address_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end

    describe "GET skip_to_manual_address_company_address_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "company_address_form")
          end

          context "when the skip_to_manual_address action is triggered" do
            it "returns a 302 response" do
              get skip_to_manual_address_company_address_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the company_address_manual form" do
              get skip_to_manual_address_company_address_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_company_address_manual_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the skip_to_manual_address action is triggered" do
            it "returns a 302 response" do
              get skip_to_manual_address_company_address_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get skip_to_manual_address_company_address_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
