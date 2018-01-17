require "rails_helper"

RSpec.describe "ServiceProvidedForms", type: :request do
  describe "GET new_service_provided_path" do
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
                 workflow_state: "service_provided_form")
        end

        it "returns a success response" do
          get new_service_provided_form_path(transient_registration[:reg_identifier])
          expect(response).to have_http_status(200)
        end
      end

      context "when a transient registration is in a different state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "renewal_start_form")
        end

        it "redirects to the form for the current state" do
          get new_service_provided_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST service_provided_forms_path" do
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
                 workflow_state: "service_provided_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              is_main_service: "true"
            }
          }

          it "updates the transient registration" do
            post service_provided_forms_path, service_provided_form: valid_params
            expect(transient_registration.reload[:is_main_service]).to eq(true)
          end

          it "returns a 302 response" do
            post service_provided_forms_path, service_provided_form: valid_params
            expect(response).to have_http_status(302)
          end

          context "when the business only carries waste it produces" do
            before(:each) { valid_params[:is_main_service] = "false" }

            it "redirects to the construction_demolition form" do
              post service_provided_forms_path, service_provided_form: valid_params
              expect(response).to redirect_to(new_construction_demolition_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business carries waste produced by others" do
            before(:each) { valid_params[:is_main_service] = "true" }

            it "redirects to the waste_types form" do
              post service_provided_forms_path, service_provided_form: valid_params
              expect(response).to redirect_to(new_waste_types_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              is_main_service: "foo"
            }
          }

          it "returns a 302 response" do
            post service_provided_forms_path, service_provided_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post service_provided_forms_path, service_provided_form: invalid_params
            expect(transient_registration.reload[:is_main_service]).to_not eq(invalid_params[:is_main_service])
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

        let(:valid_params) {
          {
            reg_identifier: transient_registration[:reg_identifier],
            is_main_service: "false"
          }
        }

        it "does not update the transient registration" do
          post service_provided_forms_path, service_provided_form: valid_params
          expect(transient_registration.reload[:is_main_service]).to_not eq(false)
        end

        it "returns a 302 response" do
          post service_provided_forms_path, service_provided_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post service_provided_forms_path, service_provided_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_service_provided_forms_path" do
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
                 workflow_state: "service_provided_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_service_provided_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the other_businesses form" do
            get back_service_provided_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_other_businesses_form_path(transient_registration[:reg_identifier]))
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
            get back_service_provided_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_service_provided_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
