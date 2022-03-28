# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RegistrationNumberForms", type: :request do
    include_examples "GET flexible form", "registration_number_form"

    describe "POST registration_number_forms_path" do
      before do
        allow_any_instance_of(DefraRuby::Validators::CompaniesHouseService).to receive(:status).and_return(:active)
      end

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
                   workflow_state: "registration_number_form")
          end

          context "when valid params are submitted" do
            let(:valid_params) { { company_no: "12345678" } }

            it "returns a 302 response and redirects to the check_registered_company_name form" do
              post registration_number_forms_path(transient_registration[:token]), params: { registration_number_form: valid_params }

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_check_registered_company_name_form_path(transient_registration[:token]))
            end
          end

          context "when invalid params are submitted" do
            let(:invalid_params) { { company_no: "" } }

            it "does not update the transient registration" do
              post registration_number_forms_path(transient_registration[:token]), params: { registration_number_form: invalid_params }
              expect(transient_registration.reload[:token].to_s).to_not eq(invalid_params[:token])
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:new_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          let(:valid_params) { { company_no: "01234567" } }

          it "does not update the transient registration, returns a 302 response and redirects to the correct form for the state" do
            post registration_number_forms_path(transient_registration[:token]), params: { registration_number_form: valid_params }

            expect(transient_registration.reload[:company_no].to_s).to_not eq(valid_params[:company_no])
            expect(response).to have_http_status(302)
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
          end
        end
      end
    end

    describe "GET back_registration_number_forms_path" do
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
                   workflow_state: "registration_number_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the renewal_information form" do
              get back_registration_number_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_cbd_type_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:new_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_registration_number_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
