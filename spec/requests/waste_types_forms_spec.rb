require "rails_helper"
require "support/shared_examples/request_get_locked_in_form"

RSpec.describe "WasteTypesForms", type: :request do
  include_examples "GET locked-in form", form = "waste_types_form"

  describe "POST waste_types_forms_path" do
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
                 workflow_state: "waste_types_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              only_amf: "true"
            }
          }

          it "updates the transient registration" do
            post waste_types_forms_path, waste_types_form: valid_params
            expect(transient_registration.reload[:only_amf]).to eq(true)
          end

          it "returns a 302 response" do
            post waste_types_forms_path, waste_types_form: valid_params
            expect(response).to have_http_status(302)
          end

          context "when the registration should change to lower tier" do
            before(:each) do
              transient_registration.update_attributes(other_businesses: true)
              transient_registration.update_attributes(is_main_service: true)

              valid_params[:only_amf] = "true"
            end

            it "redirects to the cannot_renew_lower_tier form" do
              post waste_types_forms_path, waste_types_form: valid_params
              expect(response).to redirect_to(new_cannot_renew_lower_tier_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the registration should stay upper tier" do
            before(:each) do
              transient_registration.update_attributes(other_businesses: true)
              transient_registration.update_attributes(is_main_service: true)

              valid_params[:only_amf] = "false"
            end

            it "redirects to the cbd_type form" do
              post waste_types_forms_path, waste_types_form: valid_params
              expect(response).to redirect_to(new_cbd_type_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              only_amf: "foo"
            }
          }

          it "returns a 302 response" do
            post waste_types_forms_path, waste_types_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post waste_types_forms_path, waste_types_form: invalid_params
            expect(transient_registration.reload[:only_amf]).to_not eq(invalid_params[:only_amf])
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
            only_amf: "false"
          }
        }

        it "does not update the transient registration" do
          post waste_types_forms_path, waste_types_form: valid_params
          expect(transient_registration.reload[:only_amf]).to_not eq(false)
        end

        it "returns a 302 response" do
          post waste_types_forms_path, waste_types_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post waste_types_forms_path, waste_types_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_waste_types_forms_path" do
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
                 workflow_state: "waste_types_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_waste_types_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the service_provided form" do
            get back_waste_types_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_service_provided_form_path(transient_registration[:reg_identifier]))
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
            get back_waste_types_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_waste_types_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
