# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe AddressLookupService do
    describe ".run" do
      it "does send a request to os places using the defra ruby gem" do
        postcode = "BS1 2AF"

        expect(DefraRuby::Address::OsPlacesAddressLookupService).to receive(:run).with(postcode)

        described_class.run(postcode)
      end
    end
  end
end
