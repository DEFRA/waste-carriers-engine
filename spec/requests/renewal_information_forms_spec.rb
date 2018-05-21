require "rails_helper"

RSpec.describe "RenewalInformationForms", type: :request do
  include_examples "GET locked-in form", form = "renewal_information_form"

  describe "POST renewal_information_forms_path" do
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
                 workflow_state: "renewal_information_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier]
            }
          }

          it "returns a 302 response" do
            post renewal_information_forms_path, renewal_information_form: valid_params
            expect(response).to have_http_status(302)
          end

          context "when the business type is localAuthority" do
            before(:each) { transient_registration.update_attributes(business_type: "localAuthority") }

            it "redirects to the company_name form" do
              post renewal_information_forms_path, renewal_information_form: valid_params
              expect(response).to redirect_to(new_company_name_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business type is limitedCompany" do
            before(:each) { transient_registration.update_attributes(business_type: "limitedCompany") }

            it "redirects to the registration_number form" do
              post renewal_information_forms_path, renewal_information_form: valid_params
              expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business type is limitedLiabilityPartnership" do
            before(:each) { transient_registration.update_attributes(business_type: "limitedLiabilityPartnership") }

            it "redirects to the registration_number form" do
              post renewal_information_forms_path, renewal_information_form: valid_params
              expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the location is overseas" do
            before(:each) { transient_registration.update_attributes(location: "overseas") }

            it "redirects to the company_name form" do
              post renewal_information_forms_path, renewal_information_form: valid_params
              expect(response).to redirect_to(new_company_name_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business type is partnership" do
            before(:each) { transient_registration.update_attributes(business_type: "partnership") }

            it "redirects to the company_name form" do
              post renewal_information_forms_path, renewal_information_form: valid_params
              expect(response).to redirect_to(new_company_name_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business type is soleTrader" do
            before(:each) { transient_registration.update_attributes(business_type: "soleTrader") }

            it "redirects to the company_name form" do
              post renewal_information_forms_path, renewal_information_form: valid_params
              expect(response).to redirect_to(new_company_name_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo"
            }
          }

          it "returns a 302 response" do
            post renewal_information_forms_path, renewal_information_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post renewal_information_forms_path, renewal_information_form: invalid_params
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
            reg_identifier: transient_registration[:reg_identifier]
          }
        }

        it "returns a 302 response" do
          post renewal_information_forms_path, renewal_information_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post renewal_information_forms_path, renewal_information_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_renewal_information_forms_path" do
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
                 workflow_state: "renewal_information_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_renewal_information_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the cbd_type form" do
            get back_renewal_information_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_cbd_type_form_path(transient_registration[:reg_identifier]))
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
            get back_renewal_information_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_renewal_information_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
