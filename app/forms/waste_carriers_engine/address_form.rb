# frozen_string_literal: true

module WasteCarriersEngine
  class AddressForm < BaseForm
    attr_accessor :temp_addresses
    attr_accessor :temp_address
    attr_accessor :addresses

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.addresses = add_or_replace_address(params[:temp_address])
      attributes = { addresses: addresses }

      super(attributes, params[:reg_identifier])
    end

    validates :addresses, presence: true

    private

    # Look up addresses based on the temp_postcode
    def look_up_addresses
      if temp_postcode.present?
        address_finder = AddressFinderService.new(temp_postcode)
        self.temp_addresses = address_finder.search_by_postcode
      else
        self.temp_addresses = []
      end
    end

    # If an address has already been assigned to the transient registration, pre-select it
    def preselect_existing_address
      return unless can_preselect_address?

      selected_address = temp_addresses.detect { |address| address["uprn"] == saved_address.uprn.to_s }
      self.temp_address = selected_address["uprn"] if selected_address.present?
    end

    def can_preselect_address?
      return false unless saved_address
      return false unless saved_address.uprn.present?

      true
    end

    def add_or_replace_address(selected_address_uprn)
      return if selected_address_uprn.blank?

      data = temp_addresses.detect { |address| address["uprn"] == selected_address_uprn }
      address = Address.create_from_os_places_data(data)
      address.assign_attributes(address_type: address_type)

      # Update the transient object's nested addresses, replacing any existing address of the same type
      updated_addresses = @transient_registration.addresses
      updated_addresses.delete(saved_address) if saved_address
      updated_addresses << address
      updated_addresses
    end

    # Methods which are called in this class but defined in subclasses
    # We should throw descriptive errors in case an additional subclass of ManualAddressForm is ever added

    def temp_postcode
      implemented_in_subclass
    end

    def saved_address
      implemented_in_subclass
    end

    def address_type
      implemented_in_subclass
    end

    def implemented_in_subclass
      raise NotImplementedError, "This #{self.class} cannot respond to:"
    end
  end
end
