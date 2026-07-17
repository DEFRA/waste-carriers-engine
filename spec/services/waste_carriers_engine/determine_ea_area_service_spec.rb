# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DetermineEaAreaService do
    describe ".run" do
      subject(:run_service) { described_class.run(easting: easting, northing: northing) }

      # Bristol city centre, inside the factory's default "Wessex" polygon
      let(:easting) { 358_130 }
      let(:northing) { 172_688 }

      before { create(:ea_public_face_area) }

      context "when an area contains the point" do
        it "returns the name of the area" do
          expect(run_service).to eq("Wessex")
        end
      end

      context "when the easting and northing are strings with leading zeros" do
        let(:easting) { "0358130" }
        let(:northing) { "0172688" }

        it "returns the name of the area" do
          expect(run_service).to eq("Wessex")
        end
      end

      context "when no area contains the point" do
        # Edinburgh city centre
        let(:easting) { 325_871 }
        let(:northing) { 673_557 }

        it "returns 'Outside England'" do
          expect(run_service).to eq("Outside England")
        end
      end

      context "when the point is on the boundary between two areas" do
        before do
          # A second area whose western edge passes exactly through the point
          point = ConvertEastingNorthingToLatLonService.run(easting: easting, northing: northing)

          create(:ea_public_face_area,
                 code: "EST",
                 name: "East",
                 area: {
                   "type" => "Polygon",
                   "coordinates" => [[
                     [point[:longitude], 51.3],
                     [point[:longitude] + 0.2, 51.3],
                     [point[:longitude] + 0.2, 51.6],
                     [point[:longitude], 51.6],
                     [point[:longitude], 51.3]
                   ]]
                 })
        end

        it "returns the first matching area" do
          expect(run_service).to eq("Wessex").or eq("East")
        end
      end

      context "when the easting is missing" do
        let(:easting) { nil }

        it "returns nil" do
          expect(run_service).to be_nil
        end
      end

      context "when the coordinates are not numeric" do
        let(:easting) { "foo" }
        let(:northing) { "bar" }

        it "returns nil" do
          expect(run_service).to be_nil
        end
      end

      context "when the coordinates are zero" do
        let(:easting) { 0 }
        let(:northing) { 0 }

        it "returns nil without looking up an area" do
          allow(EaPublicFaceArea).to receive(:find_by_coordinates)

          expect(run_service).to be_nil
          expect(EaPublicFaceArea).not_to have_received(:find_by_coordinates)
        end
      end

      context "when the coordinates are out of range" do
        let(:easting) { 9_999_999 }
        let(:northing) { 9_999_999 }

        it "returns nil" do
          expect(run_service).to be_nil
        end
      end

      context "when the lookup fails" do
        before do
          allow(EaPublicFaceArea).to receive(:find_by_coordinates).and_raise(Mongo::Error::OperationFailure)
          allow(Airbrake).to receive(:notify)
        end

        it "notifies Airbrake and re-raises the error" do
          expect { run_service }.to raise_error(Mongo::Error::OperationFailure)

          expect(Airbrake).to have_received(:notify)
        end
      end
    end
  end
end
