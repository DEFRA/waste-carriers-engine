# frozen_string_literal: true

module WasteCarriersEngine
  # Determines which EA area contains an easting and northing by querying
  # the EA area boundaries stored in MongoDB.
  class DetermineEaAreaService < BaseService
    # The extent of the British National Grid
    MAX_EASTING = 700_000
    MAX_NORTHING = 1_300_000

    def run(easting:, northing:)
      easting = numeric_coordinate(easting)
      northing = numeric_coordinate(northing)

      return nil unless valid_coordinates?(easting, northing)

      area = EaPublicFaceArea.find_by_coordinates(easting: easting, northing: northing)
      area&.name || EaPublicFaceArea::OUTSIDE_ENGLAND_NAME
    rescue StandardError => e
      Airbrake.notify(e, easting: easting, northing: northing) if defined?(Airbrake)
      Rails.logger.error "EA area lookup failed:\n #{e}"
      raise
    end

    private

    def numeric_coordinate(value)
      Float(value)
    rescue ArgumentError, TypeError
      nil
    end

    def valid_coordinates?(easting, northing)
      return false if easting.nil? || northing.nil?
      return false if failed_lookup_coordinates?(easting, northing)

      (0..MAX_EASTING).cover?(easting) && (0..MAX_NORTHING).cover?(northing)
    end

    # The postcode lookup stores 0,0 when a lookup has failed
    def failed_lookup_coordinates?(easting, northing)
      easting.zero? || northing.zero?
    end
  end
end
