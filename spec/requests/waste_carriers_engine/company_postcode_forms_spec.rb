# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CompanyPostcodeForms", type: :request do
    include_examples "GET flexible form", "company_postcode_form"

    describe "POST company_postcode_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "company_postcode_form")
          end

          context "when valid params are submitted" do
            let(:valid_params) do
              {
                token: transient_registration[:token],
                temp_company_postcode: "BS1 6AH"
              }
            end

            before do
              stub_address_finder_service
            end

            it "updates the transient registration, returns a 302 response and redirects to the company_address form" do
              post company_postcode_forms_path(transient_registration.token), params: { company_postcode_form: valid_params }

              expect(transient_registration.reload[:temp_company_postcode]).to eq(valid_params[:temp_company_postcode])
              expect(response).to have_http_status(:found)
              expect(response).to redirect_to(new_company_address_form_path(transient_registration[:token]))
            end

            context "when a postcode search returns an error" do
              before do
                response = double(:response, successful?: false, error: "foo")

                allow(DefraRuby::Address::OsPlacesAddressLookupService).to receive(:run).and_return(response)
              end

              it "redirects to the company_address_manual form" do
                post company_postcode_forms_path(transient_registration.token), params: { company_postcode_form: valid_params }

                expect(response).to redirect_to(new_company_address_manual_form_path(transient_registration[:token]))
              end
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form",
                   temp_company_postcode: "BS2 6AH")
          end

          let(:valid_params) do
            {
              temp_company_postcode: "BS1 5AH"
            }
          end

          it "does not update the transient registration, returns a 302 response and redirects to the correct form for the state" do
            post company_postcode_forms_path(transient_registration.token), params: { company_postcode_form: valid_params }

            expect(transient_registration.reload[:temp_company_postcode]).not_to eq(valid_params[:temp_company_postcode])
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
          end
        end
      end
    end

    describe "GET skip_to_manual_address_company_postcode_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "company_postcode_form")
          end

          context "when the skip_to_manual_address action is triggered" do
            it "returns a 302 response and redirects to the company_address_manual form" do
              get skip_to_manual_address_company_postcode_forms_path(transient_registration[:token])

              expect(response).to have_http_status(:found)
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
            it "returns a 302 response and redirects to the correct form for the state" do
              get skip_to_manual_address_company_postcode_forms_path(transient_registration[:token])

              expect(response).to have_http_status(:found)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
