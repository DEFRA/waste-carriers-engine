require "rails_helper"
require "support/shared_examples/request_get_locked_in_form"

RSpec.describe "CbdTypeForms", type: :request do
  include_examples "GET locked-in form", form = "cbd_type_form"

  describe "POST cbd_type_forms_path" do
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
                 workflow_state: "cbd_type_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              registration_type: "broker_dealer"
            }
          }

          it "updates the transient registration" do
            post cbd_type_forms_path, cbd_type_form: valid_params
            expect(transient_registration.reload[:registration_type]).to eq(valid_params[:registration_type])
          end

          it "returns a 302 response" do
            post cbd_type_forms_path, cbd_type_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the renewal_information form" do
            post cbd_type_forms_path, cbd_type_form: valid_params
            expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              registration_type: "bar"
            }
          }

          it "returns a 302 response" do
            post cbd_type_forms_path, cbd_type_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post cbd_type_forms_path, cbd_type_form: invalid_params
            expect(transient_registration.reload[:registration_type]).to_not eq(invalid_params[:registration_type])
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
            registration_type: "broker_dealer"
          }
        }

        it "does not update the transient registration" do
          post business_type_forms_path, business_type_form: valid_params
          expect(transient_registration.reload[:registration_type]).to_not eq(valid_params[:registration_type])
        end

        it "returns a 302 response" do
          post cbd_type_forms_path, cbd_type_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post cbd_type_forms_path, cbd_type_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_cbd_type_forms_path" do
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
                 workflow_state: "cbd_type_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_cbd_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          context "when the business doesn't carry waste for other businesses or households" do
            before(:each) { transient_registration.update_attributes(other_businesses: false) }

            it "redirects to the construction_demolition form" do
              get back_cbd_type_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_construction_demolition_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business carries waste produced by its customers" do
            before(:each) do
              transient_registration.update_attributes(other_businesses: true,
                                                       is_main_service: true)
            end

            it "redirects to the waste_types form" do
              get back_cbd_type_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_waste_types_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business carries waste for other businesses but produces that waste" do
            before(:each) do
              transient_registration.update_attributes(other_businesses: true,
                                                       is_main_service: false)
            end

            it "redirects to the construction_demolition form" do
              get back_cbd_type_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_construction_demolition_form_path(transient_registration[:reg_identifier]))
            end
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
            get back_cbd_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_cbd_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
