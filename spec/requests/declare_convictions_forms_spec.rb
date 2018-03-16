require "rails_helper"

RSpec.describe "DeclareConvictionsForms", type: :request do
  describe "GET new_declare_convictions_path" do
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
                 workflow_state: "declare_convictions_form")
        end

        it "returns a success response" do
          get new_declare_convictions_form_path(transient_registration[:reg_identifier])
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
          get new_declare_convictions_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST declare_convictions_forms_path" do
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
                 workflow_state: "declare_convictions_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              declared_convictions: "true"
            }
          }

          it "updates the transient registration" do
            post declare_convictions_forms_path, declare_convictions_form: valid_params
            expect(transient_registration.reload[:declared_convictions]).to eq(true)
          end

          it "returns a 302 response" do
            post declare_convictions_forms_path, declare_convictions_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the conviction_details form" do
            post declare_convictions_forms_path, declare_convictions_form: valid_params
            expect(response).to redirect_to(new_conviction_details_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              declared_convictions: "bar"
            }
          }

          it "returns a 302 response" do
            post declare_convictions_forms_path, declare_convictions_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post declare_convictions_forms_path, declare_convictions_form: invalid_params
            expect(transient_registration.reload[:declared_convictions]).to_not eq(invalid_params[:declared_convictions])
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
            declared_convictions: "true"
          }
        }

        it "does not update the transient registration" do
          post declare_convictions_forms_path, declare_convictions_form: valid_params
          expect(transient_registration.reload[:declared_convictions]).to_not eq(valid_params[:declared_convictions])
        end

        it "returns a 302 response" do
          post declare_convictions_forms_path, declare_convictions_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post declare_convictions_forms_path, declare_convictions_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_declare_convictions_forms_path" do
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
                 workflow_state: "declare_convictions_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_declare_convictions_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the key_people form" do
            get back_declare_convictions_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_key_people_form_path(transient_registration[:reg_identifier]))
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
            get back_declare_convictions_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_declare_convictions_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
