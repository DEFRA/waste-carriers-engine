require "rails_helper"

RSpec.describe "RegistrationNumberForms", type: :request do
  include_examples "GET flexible form", form = "registration_number_form"

  describe "POST registration_number_forms_path" do
    before do
      allow_any_instance_of(CompaniesHouseService).to receive(:status).and_return(:active)
    end

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

        context "when valid params are submitted and the company_no is the same as the original registration" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              company_no: transient_registration[:company_no]
            }
          }

          it "returns a 302 response" do
            post registration_number_forms_path, registration_number_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the company_name form" do
            post registration_number_forms_path, registration_number_form: valid_params
            expect(response).to redirect_to(new_company_name_form_path(transient_registration[:reg_identifier]))
          end

          context "when the original registration had a shorter variant of the company_no" do
            before(:each) do
              registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
              registration.update_attributes(company_no: "9360070")
            end

            it "returns a 302 response" do
              post registration_number_forms_path, registration_number_form: valid_params
              expect(response).to have_http_status(302)
            end

            it "redirects to the company_name form" do
              post registration_number_forms_path, registration_number_form: valid_params
              expect(response).to redirect_to(new_company_name_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when valid params are submitted and the company_no is different to the original registration" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              company_no: "01234567"
            }
          }

          it "updates the transient registration" do
            post registration_number_forms_path, registration_number_form: valid_params
            expect(transient_registration.reload[:company_no].to_s).to eq(valid_params[:company_no])
          end

          it "returns a 302 response" do
            post registration_number_forms_path, registration_number_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the cannot_renew_company_no_change form" do
            post registration_number_forms_path, registration_number_form: valid_params
            expect(response).to redirect_to(new_cannot_renew_company_no_change_form_path(transient_registration[:reg_identifier]))
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
            company_no: "01234567"
          }
        }

        it "does not update the transient registration" do
          post registration_number_forms_path, registration_number_form: valid_params
          expect(transient_registration.reload[:company_no].to_s).to_not eq(valid_params[:company_no])
        end

        it "returns a 302 response" do
          post registration_number_forms_path, registration_number_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post registration_number_forms_path, registration_number_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
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
