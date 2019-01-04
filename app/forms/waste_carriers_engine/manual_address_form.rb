module WasteCarriersEngine
  class ManualAddressForm < BaseForm
    include CanNavigateFlexibly

    attr_accessor :business_type
    attr_accessor :addresses
    attr_accessor :os_places_error
    # We pass the following attributes in to create a new Address
    attr_accessor :house_number, :address_line_1, :address_line_2, :town_city, :postcode, :country

    def initialize(transient_registration)
      super
      # We use this for the correct microcopy and to determine what fields to show
      self.business_type = @transient_registration.business_type

      # Check if the user reached this page through an OS Places error
      # Then wipe the temp attribute as we only need it for routing
      self.os_places_error = @transient_registration.temp_os_places_error
      @transient_registration.update_attributes(temp_os_places_error: nil)

      # Prefill the existing address unless the temp_postcode has changed from the existing address's postcode
      # Otherwise, just fill in the temp_postcode
      saved_address_still_valid? ? prefill_existing_address : self.postcode = saved_temp_postcode
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.house_number = params[:house_number]
      self.address_line_1 = params[:address_line_1]
      self.address_line_2 = params[:address_line_2]
      self.town_city = params[:town_city]
      self.postcode = params[:postcode]
      self.country = params[:country]
      attributes = { addresses: add_or_replace_address(params) }

      super(attributes, params[:reg_identifier])
    end

    validates :house_number, presence: true, length: { maximum: 200 }
    validates :address_line_1, presence: true, length: { maximum: 160 }
    validates :address_line_2, length: { maximum: 70 }
    validates :town_city, presence: true, length: { maximum: 30 }
    validates :postcode, length: { maximum: 30 }
    validates :country, presence: true, if: :overseas?
    validates :country, length: { maximum: 50 }

    def overseas?
      business_type == "overseas"
    end

    private

    def saved_address_still_valid?
      return true if overseas?
      return false unless existing_address
      return true if saved_temp_postcode.blank?
      return true if saved_temp_postcode == existing_address.postcode
      false
    end

    def prefill_existing_address
      return unless existing_address
      self.house_number = existing_address.house_number
      self.address_line_1 = existing_address.address_line_1
      self.address_line_2 = existing_address.address_line_2
      self.town_city = existing_address.town_city
      self.postcode = existing_address.postcode
      self.country = existing_address.country
    end

    def add_or_replace_address(params)
      address = Address.create_from_manual_entry(params, @transient_registration.overseas?)
      address.assign_attributes(address_type: address_type)

      # Update the transient object's nested addresses, replacing any existing registered address
      updated_addresses = @transient_registration.addresses
      updated_addresses.delete(existing_address) if existing_address
      updated_addresses << address
      updated_addresses
    end

    # Methods which are called in this class but defined in subclasses
    # We should throw descriptive errors in case an additional subclass of ManualAddressForm is ever added

    def saved_temp_postcode
      implemented_in_subclass
    end

    def existing_address
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
