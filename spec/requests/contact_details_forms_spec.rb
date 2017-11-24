require "rails_helper"

RSpec.describe "ContactDetailsForms", type: :request do
  describe "GET new_contact_details_form_path" do
    context "when a registration exists" do
      let(:registration) { create(:registration, :has_required_data) }

      it "returns a success response" do
        get new_contact_details_form_path(registration[:id])
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "POST contact_details_forms_path" do
    context "when a registration exists" do
      let(:registration) { create(:registration, :has_required_data) }

      context "when valid params are submitted" do
        let(:valid_params) {
          {
            firstName: "Steve",
            lastName: "Harrington",
            phoneNumber: "01234 567890",
            contactEmail: "test@example.com",
            id: registration[:id]
          }
        }

        it "updates the registration" do
          post contact_details_forms_path, contact_details_form: valid_params
          updated_registration = Registration.find(registration[:id])

          expect(updated_registration.firstName).to eq(valid_params[:firstName])
          expect(updated_registration.lastName).to eq(valid_params[:lastName])
          expect(updated_registration.phoneNumber).to eq(valid_params[:phoneNumber])
          expect(updated_registration.contactEmail).to eq(valid_params[:contactEmail])
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
            firstName: "",
            lastName: "",
            phoneNumber: "",
            contactEmail: "",
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
