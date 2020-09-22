# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewRegistrationForms", type: :request do
    describe "GET new_renew_registration_form_path" do
      context "when no new registration exists" do
        it "redirects to the invalid page" do
          get new_renew_registration_form_path("wibblewobblejellyonaplate")

          expect(response).to redirect_to(page_path("invalid"))
        end
      end

      context "when a valid new registration exists" do
        let(:transient_registration) do
          create(
            :new_registration,
            workflow_state: "renew_registration_form"
          )
        end

        context "when the workflow_state is correct" do
          it "returns a 200 status and renders the :new template" do
            get new_renew_registration_form_path(transient_registration.token)

            expect(response).to have_http_status(200)
            expect(response).to render_template(:new)
          end
        end

        context "when the workflow_state is not correct" do
          before do
            transient_registration.update_attributes(workflow_state: "payment_summary_form")
          end

          it "redirects to the correct page" do
            get new_renew_registration_form_path(transient_registration.token)

            expect(response).to redirect_to(new_payment_summary_form_path(transient_registration.token))
          end
        end
      end
    end

    describe "POST renew_registration_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:new_registration,
                   workflow_state: "renew_registration_form")
          end

          context "when valid params are submitted and the registration can be renewed" do
            let(:registration) { create(:registration, :has_required_data, :expires_soon) }
            let(:valid_params) { { temp_lookup_number: registration.reg_identifier } }

            it "returns a 302 response and redirects to the renewal_start form" do
              post renew_registration_forms_path(transient_registration[:token]), params: { renew_registration_form: valid_params }

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(registration.reg_identifier))
            end

            context "when the params are lowercase" do
              let(:valid_params) { { temp_lookup_number: registration.reg_identifier.downcase } }

              it "returns a 302 response and redirects to the renewal_start form" do
                post renew_registration_forms_path(transient_registration[:token]), params: { renew_registration_form: valid_params }

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_renewal_start_form_path(registration.reg_identifier))
              end
            end
          end

          context "when valid params are submitted and the registration cannot be renewed" do
            let(:registration) { create(:registration, :has_required_data, :expires_later) }
            let(:valid_params) { { temp_lookup_number: registration.reg_identifier } }

            it "returns a 200 response and renders the new template" do
              post renew_registration_forms_path(transient_registration[:token]), params: { renew_registration_form: valid_params }

              expect(response).to have_http_status(200)
              expect(response).to render_template("waste_carriers_engine/renew_registration_forms/new")
            end
          end

          context "when invalid params are submitted" do
            let(:invalid_params) { { company_no: "" } }

            it "returns a 200 response and renders the new template" do
              post renew_registration_forms_path(transient_registration[:token]), params: { renew_registration_form: invalid_params }

              expect(response).to have_http_status(200)
              expect(response).to render_template("waste_carriers_engine/renew_registration_forms/new")
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   workflow_state: "contact_name_form",
                   account_email: user.email)
          end

          let(:valid_params) { { company_no: "01234567" } }

          it "returns a 302 response, redirects to the correct form for the state and set magic link route to false" do
            post renew_registration_forms_path(transient_registration[:token]), params: { renew_registration_form: valid_params }

            transient_registration.reload

            expect(response).to have_http_status(302)
            expect(response).to redirect_to(new_contact_name_form_path(transient_registration[:token]))

            expect(transient_registration.from_magic_link).to be_falsey
          end
        end
      end
    end

    describe "GET back_renew_registration_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:new_registration,
                   workflow_state: "renew_registration_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the start form" do
              get back_renew_registration_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_start_form_path(params: { token: transient_registration[:token] }))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:new_registration,
                   workflow_state: "contact_name_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the correct form for the state" do
              get back_renew_registration_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_contact_name_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
