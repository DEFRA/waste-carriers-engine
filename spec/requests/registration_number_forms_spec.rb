require "rails_helper"

RSpec.describe "RegistrationNumberForms", type: :request do
  describe "GET new_registration_number_path" do
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
                 workflow_state: "registration_number_form")
        end

        it "returns a success response" do
          get new_registration_number_form_path(transient_registration[:reg_identifier])
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
          get new_registration_number_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST registration_number_forms_path" do
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
                 workflow_state: "registration_number_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              company_no: "09360070"
            }
          }

          it "updates the transient registration" do
            VCR.use_cassette("registration_number_form_valid_company_no") do
              post registration_number_forms_path, registration_number_form: valid_params
              expect(transient_registration.reload[:company_no].to_s).to eq(valid_params[:company_no])
            end
          end

          it "returns a 302 response" do
            VCR.use_cassette("registration_number_form_valid_company_no") do
              post registration_number_forms_path, registration_number_form: valid_params
              expect(response).to have_http_status(302)
            end
          end

          it "redirects to the company_name form" do
            VCR.use_cassette("registration_number_form_valid_company_no") do
              post registration_number_forms_path, registration_number_form: valid_params
              expect(response).to redirect_to(new_company_name_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              company_no: ""
            }
          }

          it "returns a 302 response" do
            post registration_number_forms_path, registration_number_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post registration_number_forms_path, registration_number_form: invalid_params
            expect(transient_registration.reload[:reg_identifier].to_s).to_not eq(invalid_params[:reg_identifier])
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
            company_no: "01709418" # This must be a real, active company to pass validation
          }
        }

        it "does not update the transient registration" do
          VCR.use_cassette("registration_number_form_valid_company_no") do
            post registration_number_forms_path, registration_number_form: valid_params
            expect(transient_registration.reload[:company_no].to_s).to_not eq(valid_params[:company_no])
          end
        end

        it "returns a 302 response" do
          VCR.use_cassette("registration_number_form_valid_company_no") do
            post registration_number_forms_path, registration_number_form: valid_params
            expect(response).to have_http_status(302)
          end
        end

        it "redirects to the correct form for the state" do
          VCR.use_cassette("registration_number_form_valid_company_no") do
            post registration_number_forms_path, registration_number_form: valid_params
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end

  describe "GET back_registration_number_forms_path" do
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
                 workflow_state: "registration_number_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_registration_number_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the renewal_information form" do
            get back_registration_number_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:reg_identifier]))
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
            get back_registration_number_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_registration_number_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
