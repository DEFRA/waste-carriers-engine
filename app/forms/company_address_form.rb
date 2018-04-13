class CompanyAddressForm < AddressForm
  attr_accessor :business_type
  attr_accessor :temp_company_postcode

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
    self.temp_company_postcode = @transient_registration.temp_company_postcode

    look_up_addresses
    preselect_existing_address
  end

  private

  def temp_postcode
    temp_company_postcode
  end

  def saved_address
    @transient_registration.registered_address
  end

  def address_type
    "REGISTERED"
  end
end
