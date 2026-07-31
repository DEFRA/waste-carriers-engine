# frozen_string_literal: true

require "defra_ruby/address"

module WasteCarriersEngine
  # Converts a British National Grid easting and northing to the WGS84
  # latitude and longitude required by MongoDB geospatial queries.
  class ConvertEastingNorthingToLatLonService < BaseService
    def run(easting:, northing:)
      DefraRuby::Address::EastingNorthingToLatLonService.run(easting, northing)
    end
  end
end
