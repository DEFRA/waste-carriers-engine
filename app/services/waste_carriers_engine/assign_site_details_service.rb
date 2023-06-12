# frozen_string_literal: true

module WasteCarriersEngine
  class AssignSiteDetailsService < BaseService
    attr_reader :address, :registration

    delegate :postcode, :area, to: :address

    def run(registration_id:)
      @registration = Registration.find(registration_id)
      @address = @registration.company_address

      assign_area_from_postcode
    end

    private

    def assign_area_from_postcode
      return if area.present?
      return unless postcode.present?

      if registration.overseas?
        address.update(area: "Outside England")
        return
      end

      x, y = DetermineEastingAndNorthingService.run(postcode: postcode).values

      address.update(area: DetermineAreaService.run(easting: x, northing: y))
    end
  end
end
