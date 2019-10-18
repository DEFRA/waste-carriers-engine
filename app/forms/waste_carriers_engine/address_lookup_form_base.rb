# frozen_string_literal: true

module WasteCarriersEngine
  class AddressLookupFormBase < BaseForm
    attr_accessor :temp_addresses

    after_initialize :look_up_addresses

    private

    # Look up addresses based on the postcode
    def look_up_addresses
      self.temp_addresses = []

      return unless postcode.present?

      address_finder = AddressFinderService.new(postcode)
      temp_addresses = address_finder.search_by_postcode

      self.temp_addresses = temp_addresses unless temp_addresses.is_a?(Symbol)
    end

    def create_address(uprn, type)
      return {} if uprn.blank?

      data = temp_addresses.detect { |address| address["uprn"].to_i == uprn.to_i }
      return {} unless data

      address = Address.create_from_os_places_data(data)
      address.assign_attributes(address_type: type)

      address
    end
  end
end
