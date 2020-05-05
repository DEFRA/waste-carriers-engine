# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "Renews", type: :request do
    # TODO: Remove once renew via magic link is no longer behind a feature toggle
    before(:each) { allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:renew_via_magic_link).and_return(true) }

    describe "GET renew_path" do
      context "when the renew token is valid" do
        let(:registration) { create(:registration, :has_required_data) }

        it "returns a 200 response" do
          registration.generate_renew_token!

          get renew_path(token: registration.renew_token)

          expect(response).to have_http_status(200)
          expect(response.body).to include(registration.reg_identifier)
        end
      end
    end
  end
end
