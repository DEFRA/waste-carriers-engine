# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "TransientRegistration", type: :request do
    describe "GET delete_transient_registration_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          it "deletes the transient registration, returns a 302 status and redirects to the registration page" do
            transient_registration = create(:renewing_registration, :has_required_data)
            expected_count = TransientRegistration.count - 1
            redirect_path = Rails.application.routes.url_helpers.registration_path(
              reg_identifier: transient_registration.reg_identifier
            )

            get delete_transient_registration_path(transient_registration[:token])

            expect(response).to have_http_status(302)
            expect(response).to redirect_to(redirect_path)
            expect(TransientRegistration.count).to eq(expected_count)
          end
        end
      end

      context "when a valid user is not signed in" do
        it "returns a 302 status and redirects to the login page" do
          get delete_transient_registration_path("foo")

          expect(response).to have_http_status(302)
          expect(response).to redirect_to("/users/sign_in")
        end
      end
    end
  end
end
