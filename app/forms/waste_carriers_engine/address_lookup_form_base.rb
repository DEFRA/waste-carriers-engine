# frozen_string_literal: true

module WasteCarriersEngine
  class AddressLookupFormBase < BaseForm
    attr_accessor :temp_addresses

    after_initialize :look_up_addresses

    private

    # Look up addresses based on the postcode
    def look_up_addresses
      if postcode.present?
        address_finder = AddressFinderService.new(postcode)
        temp_addresses = address_finder.search_by_postcode
        if temp_addresses.is_a?(Symbol)
          self.temp_addresses = []
        else
          self.temp_addresses = temp_addresses
        end
      else
        self.temp_addresses = []
      end
    end

    def create_address(uprn, type)
      return {} if uprn.blank?

      data = temp_addresses.detect { |address| address["uprn"].to_i == uprn.to_i }
      return {} unless data

      address = Address.create_from_os_places_data(data)
      address.assign_attributes(address_type: type)

      address
    end

    def house_number_and_address_lines(data)
      attributes = {}

      lines = data["lines"]
      address_attributes = %i[house_number
                              address_line_1
                              address_line_2
                              address_line_3
                              address_line_4]
      lines.reject!(&:blank?)

      # Assign lines one at a time until we run out of lines to assign
      address_attributes.each do |attribute|
        attributes[attribute] = lines.shift

        break if lines.empty?
      end

      attributes
    end
  end
end
