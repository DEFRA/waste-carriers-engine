# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ViewCertificateLinkService do

    subject(:run_service) { described_class.run(registration: registration) }

    before do
      allow(Rails.configuration).to receive(:wcrs_fo_link_domain).and_return("http://example.com")
      registration.generate_view_certificate_token!
    end

    context "when the registration does not already have a view certificate token" do
      let(:registration) { create(:registration, :has_required_data) }

      it "returns the view certificate link with the token" do
        expected_link = "http://example.com/fo/#{registration.reg_identifier}/certificate?token=#{registration.view_certificate_token}"
        expect(run_service).to eq(expected_link)
      end
    end
  end
end
