# frozen_string_literal: true

require "breasal"

module WasteCarriersEngine
  # Converts a British National Grid easting and northing to the WGS84
  # latitude and longitude required by MongoDB geospatial queries.
  class ConvertEastingNorthingToLatLonService < BaseService
    def run(easting:, northing:)
      Breasal::EastingNorthing.new(
        easting: easting.to_f,
        northing: northing.to_f,
        type: :gb
      ).to_wgs84
    end
  end
end
