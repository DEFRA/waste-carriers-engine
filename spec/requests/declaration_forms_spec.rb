require "rails_helper"

RSpec.describe "DeclarationForms", type: :request do
  describe "GET new_declaration_path" do
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
                 workflow_state: "declaration_form")
        end

        it "returns a success response" do
          get new_declaration_form_path(transient_registration[:reg_identifier])
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
          get new_declaration_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST declaration_forms_path" do
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
                 workflow_state: "declaration_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              declaration: 1
            }
          }

          it "updates the transient registration" do
            post declaration_forms_path, declaration_form: valid_params
            expect(transient_registration.reload[:declaration]).to eq(valid_params[:declaration])
          end

          it "returns a 302 response" do
            post declaration_forms_path, declaration_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the payment_summary form" do
            post declaration_forms_path, declaration_form: valid_params
            expect(response).to redirect_to(new_payment_summary_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              declaration: "foo"
            }
          }

          it "returns a 302 response" do
            post declaration_forms_path, declaration_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post declaration_forms_path, declaration_form: invalid_params
            expect(transient_registration.reload[:declaration]).to_not eq(invalid_params[:declaration])
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
            declaration: 1
          }
        }

        it "does not update the transient registration" do
          post declaration_forms_path, declaration_form: valid_params
          expect(transient_registration.reload[:declaration]).to_not eq(valid_params[:declaration])
        end

        it "returns a 302 response" do
          post declaration_forms_path, declaration_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post declaration_forms_path, declaration_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_declaration_forms_path" do
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
                 workflow_state: "declaration_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_declaration_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the check_your_answers form" do
            get back_declaration_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_check_your_answers_form_path(transient_registration[:reg_identifier]))
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
            get back_declaration_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_declaration_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
