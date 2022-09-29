# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CeasedOrRevokedCompletionService do
    describe ".run" do
      let(:transient_registration) { double(:transient_registration) }
      let(:registration) { double(:registration) }
      let(:status) { double(:status) }
      let(:revoked_reason) { double(:revoked_reason) }
      let(:transient_registration_metadata) { double(:transient_registration_metadata) }
      let(:registration_metadata) { double(:registration_metadata) }

      before do
        allow(transient_registration).to receive(:registration).and_return(registration)
        allow(transient_registration).to receive(:metaData).and_return(transient_registration_metadata)
        allow(transient_registration_metadata).to receive(:status).and_return(status)
        allow(transient_registration_metadata).to receive(:revoked_reason).and_return(revoked_reason)
        allow(transient_registration).to receive(:destroy)

        allow(registration_metadata).to receive(:status=)
        allow(registration_metadata).to receive(:revoked_reason=)

        allow(registration).to receive(:metaData).and_return(registration_metadata)
        allow(registration).to receive(:save!)
      end

      it "copies metadata from transient object to registration" do

        described_class.run(transient_registration)

        expect(registration_metadata).to have_received(:status=).with(status)
        expect(registration_metadata).to have_received(:revoked_reason=).with(revoked_reason)

        expect(transient_registration).to have_received(:destroy)
        expect(registration).to have_received(:save!)

      end
    end
  end
end
