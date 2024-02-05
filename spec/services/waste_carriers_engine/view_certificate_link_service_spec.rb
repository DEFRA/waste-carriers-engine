# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ViewCertificateLinkService do

    subject(:run_service) { described_class.run(registration: registration, renew_token: renew_token) }

    let(:registration) { create(:registration, :has_required_data) }
    let(:renew_token) { false }

    before do
      allow(Rails.configuration).to receive(:wcrs_fo_link_domain).and_return("http://example.com")
    end

    context "when the registration does not already have a view certificate token" do
      before { registration.view_certificate_token = nil }

      it "returns the view certificate link with a new token" do
        expect(registration.view_certificate_token).to be_nil
        link = run_service
        expect(link).to include(registration.reload.view_certificate_token)
      end
    end

    context "when the registration has a view certificate token and renew_token is false" do
      before { registration.generate_view_certificate_token! }

      it "returns the view certificate link with the existing token" do
        expected_link = "http://example.com/fo/#{registration.reg_identifier}/certificate?token=#{registration.view_certificate_token}"
        expect(run_service).to eq(expected_link)
      end
    end

    context "when renew_token is true" do
      let(:renew_token) { true }

      it "regenerates the token and returns the view certificate link with the new token" do
        old_token = registration.generate_view_certificate_token!
        expect(run_service).not_to include(old_token)

        new_token = registration.reload.view_certificate_token
        expected_link = "http://example.com/fo/#{registration.reg_identifier}/certificate?token=#{new_token}"
        expect(run_service).to eq(expected_link)
        expect(new_token).not_to eq(old_token)
      end
    end
  end
end
