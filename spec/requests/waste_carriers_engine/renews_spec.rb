# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "Renews", type: :request do
    # TODO: Remove once renew via magic link is no longer behind a feature toggle
    before(:each) { allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:renew_via_magic_link).and_return(true) }

    describe "GET renew_path" do
      context "when the renew token is valid" do
        let(:registration) { create(:registration, :has_required_data, :expires_soon) }

        it "returns a 302 response, creates a new renewal registration and redirect to the renewal start form" do
          expected_count = WasteCarriersEngine::RenewingRegistration.count + 1

          get renew_path(token: registration.renew_token)

          expect(response).to have_http_status(302)
          expect(WasteCarriersEngine::RenewingRegistration.count).to eq(expected_count)

          transient_registration = registration.renewal

          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration.token))
        end

        context "when a renewal is already in progress" do
          # Because let is lazy-evaluated in our test these instances won't get
          # created until the `get()` is called. However, we are relying on
          # there already being a transient registration for the expected_count
          # to be set with a value of 1. Hence in this test we need to force
          # the instances to be initialised before the test starts.
          let!(:transient_registration) { create(:renewing_registration, :has_required_data, :expires_today, workflow_state: :business_type_form) }
          let(:registration) { transient_registration.registration }

          it "does not create a new renewal and redirects to the correct form" do
            expected_count = WasteCarriersEngine::RenewingRegistration.count

            get renew_path(token: registration.renew_token)

            expect(response).to have_http_status(302)
            expect(WasteCarriersEngine::RenewingRegistration.count).to eq(expected_count)
            expect(response).to redirect_to(new_business_type_form_path(transient_registration.token))
          end
        end

        context "when the registration has already been renewed" do
          let(:registration) { create(:registration, :has_required_data, :already_renewed) }

          it "returns a 200 response code and the correct template" do
            allow(Rails.configuration).to receive(:renewal_window).and_return(3)

            get renew_path(token: registration.renew_token)

            expect(response).to have_http_status(200)
            expect(response).to render_template(:already_renewed)
          end
        end

        context "when is too late to renew" do
          let(:registration) do
            create(:registration, :has_required_data, :past_renewal_window, renew_token: "footoken")
          end

          it "returns a 200 response code and the correct template" do
            allow(Rails.configuration).to receive(:renewal_window).and_return(3)

            get renew_path(token: registration.renew_token)

            expect(response).to have_http_status(200)
            expect(response).to render_template(:past_renewal_window)
          end
        end
      end

      context "when the renew token is invalid" do
        it "returns a 404 response code and the correct template" do
          get renew_path(token: "FooBarBaz")

          expect(response).to have_http_status(404)
          expect(response).to render_template(:invalid_magic_link)
        end
      end
    end
  end
end
