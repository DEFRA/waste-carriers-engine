# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CeasedOrRevokedCompletionService do
    describe ".run" do
      let(:transient_registration) { double(:transient_registration) }
      let(:registration) { double(:registration) }

      before do
        expect(transient_registration).to receive(:registration).and_return(registration)
      end

      it "copies metadata from transient object to registration" do
        status = double(:status)
        revoked_reason = double(:revoked_reason)
        transient_registration_metadata = double(:transient_registration_metadata)
        registration_metadata = double(:registration_metadata)

        expect(transient_registration).to receive(:metaData).and_return(transient_registration_metadata).twice
        expect(transient_registration_metadata).to receive(:status).and_return(status)
        expect(transient_registration_metadata).to receive(:revoked_reason).and_return(revoked_reason)

        expect(registration).to receive(:metaData).and_return(registration_metadata).twice
        expect(registration_metadata).to receive(:status=).with(status)
        expect(registration_metadata).to receive(:revoked_reason=).with(revoked_reason)

        expect(transient_registration).to receive(:destroy)
        expect(registration).to receive(:save!)

        described_class.run(transient_registration)
      end
    end
  end
end
