class ContactAddressForm < AddressForm
  attr_accessor :temp_contact_postcode

  def initialize(transient_registration)
    super
    self.temp_contact_postcode = @transient_registration.temp_contact_postcode

    look_up_addresses
    preselect_existing_address
  end

  private

  def temp_postcode
    temp_contact_postcode
  end

  def saved_address
    @transient_registration.contact_address
  end

  def address_type
    "CONTACT"
  end
end
