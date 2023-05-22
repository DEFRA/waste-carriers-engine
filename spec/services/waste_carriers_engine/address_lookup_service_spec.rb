# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe AddressLookupService do
    describe ".run" do
      it "does send a request to os places using the defra ruby gem" do
        postcode = "BS1 2AF"

        allow(DefraRuby::Address::OsPlacesAddressLookupService).to receive(:run)

        described_class.run(postcode)

        expect(DefraRuby::Address::OsPlacesAddressLookupService).to have_received(:run).with(postcode)
      end
    end
  end
end
