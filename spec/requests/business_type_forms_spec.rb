require "rails_helper"

RSpec.describe "BusinessTypeForms", type: :request do
  describe "GET new_business_type_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "business_type_form")
        end

        it "returns a success response" do
          get new_business_type_form_path(transient_registration[:reg_identifier])
          expect(response).to have_http_status(200)
        end
      end
    end
  end

  describe "POST business_type_forms_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "business_type_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier]
            }
          }

          it "updates the transient registration" do
            # TODO: Add test once data is submitted through the form
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

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier]
            }
          }

          it "does not update the transient registration" do
            # TODO: Add test once data is submitted through the form
          end
        end
      end
    end
  end

  describe "GET back_business_type_forms_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
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
    end
  end
end
