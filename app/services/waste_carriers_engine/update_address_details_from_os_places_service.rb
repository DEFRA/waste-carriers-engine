# frozen_string_literal: true

module WasteCarriersEngine
  class UpdateAddressDetailsFromOsPlacesService < BaseService
    attr_accessor :address

    def run(address:)
      @address = address

      update_address(address.postcode)

      @address
    end

    private

    def update_address(postcode)
      return if postcode.blank?

      response = AddressLookupService.run(postcode)

      if response.successful?
        address.update_from_os_places_data(response.results.first)
      elsif response.error.is_a?(DefraRuby::Address::NoMatchError)
        no_match_from_postcode_lookup(postcode)
      else
        error_from_postcode_lookup(postcode, response.error)
      end
    end

    def handle_error(error, message, metadata)
      Airbrake.notify(error, metadata) if defined?(Airbrake)
      Rails.logger.error(message)
    end

    def no_match_from_postcode_lookup(postcode)
      message = "Postcode to easting and northing returned no results"
      handle_error(StandardError.new(message), message, postcode: postcode)
    end

    def error_from_postcode_lookup(postcode, error)
      message = "Postcode to easting and northing errored: #{error.message}"
      handle_error(StandardError.new(message), message, postcode: postcode)
    end
  end
end
