require "rails_helper"

RSpec.describe "CompanyPostcodeForms", type: :request do
  describe "GET new_company_postcode_path" do
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
                 workflow_state: "company_postcode_form")
        end

        it "returns a success response" do
          get new_company_postcode_form_path(transient_registration[:reg_identifier])
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
          get new_company_postcode_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST company_postcode_forms_path" do
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
                 workflow_state: "company_postcode_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              temp_company_postcode: "BS1 6AH"
            }
          }

          it "returns a 302 response" do
            VCR.use_cassette("company_postcode_form_modified_postcode") do
              post company_postcode_forms_path, company_postcode_form: valid_params
              expect(response).to have_http_status(302)
            end
          end

          it "updates the transient registration" do
            VCR.use_cassette("company_postcode_form_modified_postcode") do
              post company_postcode_forms_path, company_postcode_form: valid_params
              expect(transient_registration.reload[:temp_company_postcode]).to eq(valid_params[:temp_company_postcode])
            end
          end

          it "redirects to the company_address form" do
            VCR.use_cassette("company_postcode_form_modified_postcode") do
              post company_postcode_forms_path, company_postcode_form: valid_params
              expect(response).to redirect_to(new_company_address_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when a postcode search returns an error" do
            before(:each) do
              allow_any_instance_of(AddressFinderService).to receive(:search_by_postcode).and_return(:error)
            end

            it "redirects to the company_address_manual form" do
              post company_postcode_forms_path, company_postcode_form: valid_params
              expect(response).to redirect_to(new_company_address_manual_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              temp_company_postcode: "ABC123DEF456"
            }
          }

          it "returns a 302 response" do
            post company_postcode_forms_path, company_postcode_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post company_postcode_forms_path, company_postcode_form: invalid_params
            expect(transient_registration.reload[:temp_company_postcode]).to_not eq(invalid_params[:temp_company_postcode])
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
            temp_company_postcode: "BS1 5AH"
          }
        }

        it "returns a 302 response" do
          post company_postcode_forms_path, company_postcode_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "does not update the transient registration" do
          post company_postcode_forms_path, company_postcode_form: valid_params
          expect(transient_registration.reload[:temp_company_postcode]).to_not eq(valid_params[:temp_company_postcode])
        end

        it "redirects to the correct form for the state" do
          post company_postcode_forms_path, company_postcode_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_company_postcode_forms_path" do
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
                 workflow_state: "company_postcode_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_company_postcode_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the company_name form" do
            get back_company_postcode_forms_path(transient_registration[:reg_identifier])
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
            get back_company_postcode_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_company_postcode_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end

  describe "GET skip_to_manual_address_company_postcode_forms_path" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_postcode,
                 account_email: user.email,
                 workflow_state: "company_postcode_form")
        end

        context "when the skip_to_manual_address action is triggered" do
          it "returns a 302 response" do
            get skip_to_manual_address_company_postcode_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the company_address_manual form" do
            get skip_to_manual_address_company_postcode_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_company_address_manual_form_path(transient_registration[:reg_identifier]))
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_postcode,
                 account_email: user.email,
                 workflow_state: "renewal_start_form")
        end

        context "when the skip_to_manual_address action is triggered" do
          it "returns a 302 response" do
            get skip_to_manual_address_company_postcode_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get skip_to_manual_address_company_postcode_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
