# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ConvertEastingNorthingToLatLonService do
    describe ".run" do
      subject(:result) { described_class.run(easting: easting, northing: northing) }

      # Bristol city centre; expected values from the ONS postcode database
      let(:easting) { 358_130 }
      let(:northing) { 172_688 }

      it "returns the WGS84 latitude and longitude" do
        expect(result[:latitude]).to be_within(0.0001).of(51.451616)
        expect(result[:longitude]).to be_within(0.0001).of(-2.603943)
      end

      context "when the easting and northing are strings" do
        let(:easting) { "358130" }
        let(:northing) { "172688" }

        it "returns the WGS84 latitude and longitude" do
          expect(result[:latitude]).to be_within(0.0001).of(51.451616)
          expect(result[:longitude]).to be_within(0.0001).of(-2.603943)
        end
      end

      context "with a point in the north of England" do
        # Newcastle city centre
        let(:easting) { 424_693 }
        let(:northing) { 565_147 }

        it "returns the WGS84 latitude and longitude" do
          expect(result[:latitude]).to be_within(0.0001).of(54.980327)
          expect(result[:longitude]).to be_within(0.0001).of(-1.615727)
        end
      end
    end
  end
end
