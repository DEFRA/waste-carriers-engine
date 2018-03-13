require "rails_helper"

RSpec.describe "CompanyNameForms", type: :request do
  describe "GET new_company_name_path" do
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
                 workflow_state: "company_name_form")
        end

        it "returns a success response" do
          get new_company_name_form_path(transient_registration[:reg_identifier])
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
          get new_company_name_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST company_name_forms_path" do
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
                 workflow_state: "company_name_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              company_name: "WasteCo Ltd"
            }
          }

          it "updates the transient registration" do
            post company_name_forms_path, company_name_form: valid_params
            expect(transient_registration.reload[:company_name]).to eq(valid_params[:company_name])
          end

          it "returns a 302 response" do
            post company_name_forms_path, company_name_form: valid_params
            expect(response).to have_http_status(302)
          end

          context "when the location is not overseas" do
            before(:each) { transient_registration.update_attributes(location: "england") }

            it "redirects to the company_postcode form" do
              post company_name_forms_path, company_name_form: valid_params
              expect(response).to redirect_to(new_company_postcode_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the location is overseas" do
            before(:each) { transient_registration.update_attributes(location: "overseas") }

            it "redirects to the company_address_manual form" do
              post company_name_forms_path, company_name_form: valid_params
              expect(response).to redirect_to(new_company_address_manual_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              company_name: ""
            }
          }

          it "returns a 302 response" do
            post company_name_forms_path, company_name_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post company_name_forms_path, company_name_form: invalid_params
            expect(transient_registration.reload[:company_name]).to_not eq(invalid_params[:company_name])
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
            company_name: "WasteCo Ltd"
          }
        }

        it "does not update the transient registration" do
          post company_name_forms_path, company_name_form: valid_params
          expect(transient_registration.reload[:company_name]).to_not eq(valid_params[:company_name])
        end

        it "returns a 302 response" do
          post company_name_forms_path, company_name_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post company_name_forms_path, company_name_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_company_name_forms_path" do
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
                 workflow_state: "company_name_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_company_name_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          context "when the business type is localAuthority" do
            before(:each) { transient_registration.update_attributes(business_type: "localAuthority") }

            it "redirects to the renewal_information form" do
              get back_company_name_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business type is limitedCompany" do
            before(:each) { transient_registration.update_attributes(business_type: "limitedCompany") }

            it "redirects to the registration_number form" do
              get back_company_name_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business type is limitedLiabilityPartnership" do
            before(:each) { transient_registration.update_attributes(business_type: "limitedLiabilityPartnership") }

            it "redirects to the registration_number form" do
              get back_company_name_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_registration_number_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the location is overseas" do
            before(:each) { transient_registration.update_attributes(location: "overseas") }

            it "redirects to the renewal_information form" do
              get back_company_name_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business type is partnership" do
            before(:each) { transient_registration.update_attributes(business_type: "partnership") }

            it "redirects to the renewal_information form" do
              get back_company_name_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business type is soleTrader" do
            before(:each) { transient_registration.update_attributes(business_type: "soleTrader") }

            it "redirects to the renewal_information form" do
              get back_company_name_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_information_form_path(transient_registration[:reg_identifier]))
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
            get back_company_name_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_company_name_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
