require "rails_helper"

RSpec.describe "CompanyAddressManualForms", type: :request do
  describe "GET new_company_address_manual_path" do
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
                 workflow_state: "company_address_manual_form")
        end

        it "returns a success response" do
          get new_company_address_manual_form_path(transient_registration[:reg_identifier])
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
          get new_company_address_manual_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST company_address_manual_forms_path" do
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
                 workflow_state: "company_address_manual_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              house_number: "42"
            }
          }

          it "updates the transient registration" do
            post company_address_manual_forms_path, company_address_manual_form: valid_params
            registered_address = transient_registration.reload.addresses.where(address_type: "REGISTERED").first
            expect(registered_address.house_number).to eq(valid_params[:house_number])
          end

          it "returns a 302 response" do
            post company_address_manual_forms_path, company_address_manual_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the key_people form" do
            post company_address_manual_forms_path, company_address_manual_form: valid_params
            expect(response).to redirect_to(new_key_people_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo"
            }
          }

          it "returns a 302 response" do
            post company_address_manual_forms_path, company_address_manual_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post company_address_manual_forms_path, company_address_manual_form: invalid_params
            expect(transient_registration.reload[:reg_identifier]).to_not eq(invalid_params[:reg_identifier])
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
            house_number: "42"
          }
        }

        it "does not update the transient registration" do
          post company_address_forms_path, company_address_form: valid_params
          expect(transient_registration.reload.addresses.count).to eq(0)
        end

        it "returns a 302 response" do
          post company_address_manual_forms_path, company_address_manual_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post company_address_manual_forms_path, company_address_manual_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_company_address_manual_forms_path" do
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
                 workflow_state: "company_address_manual_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_company_address_manual_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the company_name form" do
            get back_company_address_manual_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_company_name_form_path(transient_registration[:reg_identifier]))
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
            get back_company_address_manual_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_company_address_manual_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
