require "rails_helper"

RSpec.describe "ContactDetailsForms", type: :request do
  describe "GET new_contact_details_form_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a registration exists" do
        let(:registration) { create(:registration, :has_required_data) }

        it "returns a success response" do
          get new_contact_details_form_path(registration[:id])
          expect(response).to have_http_status(200)
        end
      end
    end
  end

  describe "POST contact_details_forms_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a registration exists" do
        let(:registration) { create(:registration, :has_required_data) }

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              first_name: "Steve",
              last_name: "Harrington",
              phone_number: "01234 567890",
              contact_email: "test@example.com",
              id: registration[:id]
            }
          }

          it "updates the registration" do
            post contact_details_forms_path, contact_details_form: valid_params
            updated_registration = Registration.find(registration[:id])

            expect(updated_registration.first_name).to eq(valid_params[:first_name])
            expect(updated_registration.last_name).to eq(valid_params[:last_name])
            expect(updated_registration.phone_number).to eq(valid_params[:phone_number])
            expect(updated_registration.contact_email).to eq(valid_params[:contact_email])
          end

          it "returns a 302 response" do
            post contact_details_forms_path, contact_details_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the root path" do
            post contact_details_forms_path, contact_details_form: valid_params
            expect(response).to redirect_to(registration)
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              first_name: "",
              last_name: "",
              phone_number: "",
              contact_email: "",
              id: registration[:id]
            }
          }

          it "does not update the registration" do
            original_registration = registration
            post contact_details_forms_path, contact_details_form: invalid_params
            expect(registration).to eq(original_registration)
          end
        end
      end
    end
  end
end
