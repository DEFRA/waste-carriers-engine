# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DeregistrationMagicLinkService do

    subject(:run_service) { described_class.run(registration: registration) }

    before { allow(Rails.configuration).to receive(:wcrs_fo_link_domain).and_return("http://example.com") }

    RSpec.shared_examples "magic link with token" do
      it "returns the magic link with the token" do
        expect(run_service).to eq("http://example.com/fo/deregister/#{registration.deregistration_token}")
      end
    end

    context "when the registration does not already have a deregistration token" do
      let(:registration) { create(:registration, :has_required_data) }

      it "generates a token" do
        expect { run_service }.to change(registration, :deregistration_token).from(nil)
      end

      it_behaves_like "magic link with token"
    end

    context "when the registration already has a deregistration token" do
      let(:registration) { create(:registration, :has_required_data, deregistration_token: "X123", deregistration_token_created_at: 1.month.ago) }

      it "updates the token" do
        expect { run_service }.to change(registration, :deregistration_token)
      end

      it_behaves_like "magic link with token"
    end
  end
end
