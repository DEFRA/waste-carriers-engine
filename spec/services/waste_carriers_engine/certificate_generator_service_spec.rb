# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CertificateGeneratorService do
    describe "run" do
      let(:registration) { build(:registration, :has_required_data) }
      let(:requester) { build(:user) }
      let(:view) { ActionController::Base.new.view_context }
      let(:service) { described_class.new }

      it "triggers registration.increment_certificate_version" do
        allow(registration).to receive(:increment_certificate_version)
        service.run(registration: registration, requester: requester, view: view)
        expect(registration).to have_received(:increment_certificate_version).with(requester)
      end

      it "initializes and return presenter instance" do
        allow(CertificatePresenter).to receive(:new).and_call_original
        response = service.run(registration: registration, requester: requester, view: view)
        expect(CertificatePresenter).to have_received(:new).with(registration, view)

        expect(response.class.to_s).to eq("WasteCarriersEngine::CertificatePresenter")
        expect(response.regIdentifier).to eq(registration.regIdentifier)
      end
    end
  end
end
