# frozen_string_literal: true

# spec/services/waste_carriers_engine/determine_easting_and_northing_service_spec.rb

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DetermineEastingAndNorthingService, type: :service do
    let(:service) { described_class.new }
    let(:valid_postcode) { "SW1A 1AA" }
    let(:invalid_postcode) { "INVALID" }

    describe "#run" do
      context "when given a valid postcode" do
        before do
          # Stub AddressLookupService to return a valid response
          allow(AddressLookupService).to receive(:run).with(valid_postcode).and_return(
            instance_double(DefraRuby::Address::Response, successful?: true, results: [{ "x" => 529_090, "y" => 179_645 }])
          )
        end

        it "returns the correct easting and northing values" do
          result = service.run(postcode: valid_postcode)

          expect(result[:easting]).to eq(529_090.0)
          expect(result[:northing]).to eq(179_645.0)
        end
      end

      context "when given an invalid postcode" do
        before do
          # Stub AddressLookupService to return a NoMatchError
          allow(AddressLookupService).to receive(:run).with(invalid_postcode).and_return(
            instance_double(DefraRuby::Address::Response, successful?: false, error: DefraRuby::Address::NoMatchError.new)
          )
        end

        it "returns the default easting and northing values" do
          result = service.run(postcode: invalid_postcode)

          expect(result[:easting]).to eq(0.0)
          expect(result[:northing]).to eq(0.0)
        end
      end

      context "when the postcode lookup service returns an error" do
        before do
          # Stub AddressLookupService to return a generic error
          allow(AddressLookupService).to receive(:run).with(invalid_postcode).and_return(
            instance_double(DefraRuby::Address::Response, successful?: false, error: StandardError.new("An error occurred"))
          )
        end

        it "returns the default easting and northing values" do
          result = service.run(postcode: invalid_postcode)

          expect(result[:easting]).to eq(0.0)
          expect(result[:northing]).to eq(0.0)
        end
      end
    end
  end
end
