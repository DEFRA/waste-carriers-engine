# frozen_string_literal: true

require "defra_ruby/area"

module WasteCarriersEngine
  class DetermineAreaService < BaseService
    def run(easting:, northing:)
      response = DefraRuby::Area::PublicFaceAreaService.run(easting, northing)

      return response.areas.first.long_name if response.successful?
      return "Not found" if response.error.instance_of?(DefraRuby::Area::NoMatchError)

      handle_error(response.error, easting, northing)
      "Not found"
    end

    private

    def handle_error(error, easting, northing)
      Airbrake.notify(error, easting: easting, northing: northing)
      Rails.logger.error "Area lookup failed:\n #{error}"
    end
  end
end
