require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "Registrations", type: :request do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      describe "GET /registrations" do
        it "returns a success response" do
          get registrations_path
          expect(response).to have_http_status(200)
        end
      end
    end

    context "when a user is not signed in" do
      before(:each) do
        user = create(:user)
        sign_out(user)
      end

      describe "GET /registrations" do
        it "returns a 302 response" do
          get registrations_path
          expect(response).to have_http_status(302)
        end

        it "redirects to the sign in page" do
          get registrations_path
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
