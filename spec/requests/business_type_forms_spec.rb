require "rails_helper"

RSpec.describe "BusinessTypeForms", type: :request do
  describe "GET new_business_type_path" do
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
                 workflow_state: "business_type_form")
        end

        it "returns a success response" do
          get new_business_type_form_path(transient_registration[:reg_identifier])
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
          get new_business_type_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST business_type_forms_path" do
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
                 business_type: "limitedCompany",
                 workflow_state: "business_type_form")
        end

        context "when the business type is not changed" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              business_type: "limitedCompany"
            }
          }

          it "returns a 302 response" do
            post business_type_forms_path, business_type_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the smart answers form" do
            post business_type_forms_path, business_type_form: valid_params
            expect(response).to redirect_to(new_smart_answers_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when the business type is changed and the change is allowed" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              business_type: "overseas"
            }
          }

          it "updates the transient registration" do
            post business_type_forms_path, business_type_form: valid_params
            expect(transient_registration.reload[:reg_identifier]).to eq(valid_params[:reg_identifier])
          end

          it "returns a 302 response" do
            post business_type_forms_path, business_type_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the smart answers form" do
            post business_type_forms_path, business_type_form: valid_params
            expect(response).to redirect_to(new_smart_answers_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when the business type is changed and the change is not allowed" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              business_type: "partnership"
            }
          }

          it "updates the transient registration" do
            post business_type_forms_path, business_type_form: valid_params
            expect(transient_registration.reload[:reg_identifier]).to eq(valid_params[:reg_identifier])
          end

          it "returns a 302 response" do
            post business_type_forms_path, business_type_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the 'cannot renew due to business type change' form" do
            post business_type_forms_path, business_type_form: valid_params
            expect(response).to redirect_to(new_cannot_renew_type_change_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              business_type: "foo"
            }
          }

          it "returns a 302 response" do
            post business_type_forms_path, business_type_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post business_type_forms_path, business_type_form: invalid_params
            expect(transient_registration.reload[:reg_identifier]).to_not eq(invalid_params[:reg_identifier])
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 business_type: "limitedCompany",
                 workflow_state: "renewal_start_form")
        end

        let(:valid_params) {
          {
            reg_identifier: transient_registration[:reg_identifier],
            business_type: "partnership"
          }
        }

        it "does not update the transient registration" do
          post business_type_forms_path, business_type_form: valid_params
          expect(transient_registration.reload[:business_type]).to_not eq(valid_params[:business_type])
        end

        it "returns a 302 response" do
          post business_type_forms_path, business_type_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post business_type_forms_path, business_type_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_business_type_forms_path" do
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
                 workflow_state: "business_type_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_business_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the renewal start form" do
            get back_business_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "smart_answers_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_business_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_business_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_smart_answers_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
