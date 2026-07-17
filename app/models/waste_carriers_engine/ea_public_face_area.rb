# frozen_string_literal: true

module WasteCarriersEngine
  # An EA public face area boundary. The area field holds a GeoJSON geometry
  # in WGS84 coordinates so lookups can use MongoDB geospatial queries.
  class EaPublicFaceArea
    include Mongoid::Document

    store_in collection: "ea_public_face_areas"

    OUTSIDE_ENGLAND_NAME = "Outside England"

    field :code, type: String
    field :name, type: String
    field :areaId, as: :area_id, type: Integer
    field :area, type: Hash

    validates :code, presence: true
    validates :name, presence: true

    index({ area: "2dsphere" }, { name: "area_2dsphere_index" })

    scope :containing_lat_lon, lambda { |latitude, longitude|
      where(
        area: {
          "$geoIntersects" => {
            "$geometry" => {
              "type" => "Point",
              "coordinates" => [longitude, latitude]
            }
          }
        }
      )
    }

    # A point on a boundary can be in more than one area; take the first match
    def self.find_by_coordinates(easting:, northing:)
      coordinates = ConvertEastingNorthingToLatLonService.run(easting: easting, northing: northing)

      containing_lat_lon(coordinates[:latitude], coordinates[:longitude]).only(:code, :name, :areaId).first
    end
  end
end
