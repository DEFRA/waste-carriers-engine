# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CertificateGeneratorService do
    describe "run" do
      let(:registration) { build(:registration, :has_required_data) }
      let(:requester) { build(:user) }
      let(:view) { ActionController::Base.new.view_context }
      let(:run_service) { described_class.run(registration: registration, requester: requester, view: view) }

      it "does not change the registration's certificate version" do
        expect { run_service }.not_to change { registration.metaData.certificate_version }
      end

      it "does not change the registration's certificate version history" do
        expect { run_service }.not_to change { registration.metaData.certificate_version_history }
      end

      it "initializes and returns a certificate presenter instance" do
        allow(CertificatePresenter).to receive(:new).and_call_original
        response = run_service
        expect(CertificatePresenter).to have_received(:new).with(registration, view)

        expect(response.class.to_s).to eq("WasteCarriersEngine::CertificatePresenter")
        expect(response.regIdentifier).to eq(registration.regIdentifier)
      end
    end
  end
end
