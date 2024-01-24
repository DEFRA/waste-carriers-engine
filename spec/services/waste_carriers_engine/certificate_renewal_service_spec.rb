# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CertificateRenewalService do
    describe ".run" do
      let(:registration) { create(:registration, :has_required_data) }
      let(:service) { described_class.run(registration: registration) }

      before do
        allow(registration).to receive(:generate_view_certificate_token!).and_call_original
        allow(registration).to receive(:save!).and_call_original
        allow(Notify::CertificateRenewalEmailService).to receive(:run).with(registration: registration)
      end

      context "when the process is successful" do
        it "generates a new view certificate token" do
          service
          expect(registration).to have_received(:generate_view_certificate_token!)
        end

        it "sends an email" do
          service
          expect(Notify::CertificateRenewalEmailService).to have_received(:run).with(registration: registration)
        end

        it "returns true" do
          expect(service).to be(true)
        end
      end

      context "when there is an error" do
        let(:error) { StandardError.new("Unexpected error") }

        before do
          allow(registration).to receive(:save!).and_raise(error)
          allow(Rails.logger).to receive(:error)
          allow(Airbrake).to receive(:notify) if defined?(Airbrake)
        end

        it "logs the error" do
          service
          expect(Rails.logger).to have_received(:error).with(error)
        end

        it "notifies Airbrake if defined" do
          service
          if defined?(Airbrake)
            expect(Airbrake).to have_received(:notify).with(error, registration: registration.reg_identifier)
          end
        end

        it "returns false" do
          expect(service).to be(false)
        end
      end
    end
  end
end
