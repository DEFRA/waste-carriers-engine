require "rails_helper"

RSpec.describe RegistrationsController, type: :controller do
  describe "index" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      describe "@registrations" do
        it "contains registrations belonging to the user" do
          registration = create(:registration, :has_required_data, account_email: user.email)
          get :index
          expect(assigns(:registrations)).to include(registration)
        end

        it "does not contain registrations belonging to other users" do
          registration = create(:registration, :has_required_data, account_email: "not-this-user@example.com")
          get :index
          expect(assigns(:registrations)).to_not include(registration)
        end
      end
    end
  end
end
