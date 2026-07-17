# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EaPublicFaceArea do
    # Bristol city centre
    let(:easting) { 358_130 }
    let(:northing) { 172_688 }
    let(:latitude) { 51.451616 }
    let(:longitude) { -2.603943 }

    describe "validations" do
      it "is invalid without a code" do
        expect(build(:ea_public_face_area, code: nil)).not_to be_valid
      end

      it "is invalid without a name" do
        expect(build(:ea_public_face_area, name: nil)).not_to be_valid
      end

      it "is valid with a code and a name" do
        expect(build(:ea_public_face_area)).to be_valid
      end
    end

    describe ".containing_lat_lon" do
      let!(:containing_area) { create(:ea_public_face_area) }

      before do
        # An area which does not contain the point
        create(:ea_public_face_area,
               code: "YOR",
               name: "Yorkshire",
               area: {
                 "type" => "Polygon",
                 "coordinates" => [[
                   [-1.6, 53.7], [-1.4, 53.7], [-1.4, 53.9], [-1.6, 53.9], [-1.6, 53.7]
                 ]]
               })
      end

      it "returns only the area containing the point" do
        expect(described_class.containing_lat_lon(latitude, longitude).to_a).to eq([containing_area])
      end

      it "returns no areas for a point outside all areas" do
        expect(described_class.containing_lat_lon(55.95, -3.19).to_a).to be_empty
      end

      it "supports MultiPolygon geometries" do
        containing_area.update(
          area: {
            "type" => "MultiPolygon",
            "coordinates" => [
              [[[-2.7, 51.4], [-2.5, 51.4], [-2.5, 51.5], [-2.7, 51.5], [-2.7, 51.4]]],
              [[[-3.1, 51.0], [-3.0, 51.0], [-3.0, 51.1], [-3.1, 51.1], [-3.1, 51.0]]]
            ]
          }
        )

        expect(described_class.containing_lat_lon(51.05, -3.05).to_a).to eq([containing_area])
      end
    end

    describe ".find_by_coordinates" do
      let!(:containing_area) { create(:ea_public_face_area) }

      it "converts the easting and northing and returns the containing area" do
        expect(described_class.find_by_coordinates(easting: easting, northing: northing)).to eq(containing_area)
      end

      it "returns nil when no area contains the point" do
        # Edinburgh city centre
        expect(described_class.find_by_coordinates(easting: 325_871, northing: 673_557)).to be_nil
      end
    end
  end
end
