# frozen_string_literal: true

module WasteCarriersEngine
  class AssignSiteDetailsService < BaseService
    attr_reader :address

    delegate :postcode, :area, to: :address

    def run(address:)
      @address = address

      assign_area_from_postcode
    end

    private

    def assign_area_from_postcode
      return if area.present?
      return unless postcode.present?

      x, y = DetermineEastingAndNorthingService.run(postcode: postcode).values

      address.area = DetermineAreaService.run(easting: x, northing: y)
    end
  end
end
