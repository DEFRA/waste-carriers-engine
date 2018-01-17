require "rails_helper"

RSpec.describe "OtherBusinessesForms", type: :request do
  describe "GET new_other_businesses_path" do
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
                 workflow_state: "other_businesses_form")
        end

        it "returns a success response" do
          get new_other_businesses_form_path(transient_registration[:reg_identifier])
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
          get new_other_businesses_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST other_businesses_forms_path" do
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
                 workflow_state: "other_businesses_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              other_businesses: "true"
            }
          }

          it "updates the transient registration" do
            post other_businesses_forms_path, other_businesses_form: valid_params
            expect(transient_registration.reload[:other_businesses]).to eq(true)
          end

          it "returns a 302 response" do
            post other_businesses_forms_path, other_businesses_form: valid_params
            expect(response).to have_http_status(302)
          end

          context "when the business carries waste for other business and households" do
            before(:each) { valid_params[:other_businesses] = "true" }

            it "redirects to the service_provided form" do
              post other_businesses_forms_path, other_businesses_form: valid_params
              expect(response).to redirect_to(new_service_provided_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business does not carry waste for other business and households" do
            before(:each) { valid_params[:other_businesses] = "false" }

            it "redirects to the construction_demolition form" do
              post other_businesses_forms_path, other_businesses_form: valid_params
              expect(response).to redirect_to(new_construction_demolition_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              other_businesses: "foo"
            }
          }

          it "returns a 302 response" do
            post other_businesses_forms_path, other_businesses_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post other_businesses_forms_path, other_businesses_form: invalid_params
            expect(transient_registration.reload[:other_businesses]).to_not eq(invalid_params[:other_businesses])
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
            other_businesses: "false"
          }
        }

        it "does not update the transient registration" do
          post other_businesses_forms_path, other_businesses_form: valid_params
          expect(transient_registration.reload[:other_businesses]).to_not eq(false)
        end

        it "returns a 302 response" do
          post other_businesses_forms_path, other_businesses_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post other_businesses_forms_path, other_businesses_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_other_businesses_forms_path" do
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
                 workflow_state: "other_businesses_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_other_businesses_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the business_type form" do
            get back_other_businesses_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_business_type_form_path(transient_registration[:reg_identifier]))
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
            get back_other_businesses_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_other_businesses_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
