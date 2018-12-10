# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::RegistrationsController, type: :controller do
    routes { WasteCarriersEngine::Engine.routes }

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
end
