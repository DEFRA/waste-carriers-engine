class CompanyAddressForm < BaseForm
  attr_accessor :business_type
  attr_accessor :temp_company_postcode
  attr_accessor :temp_addresses
  attr_accessor :temp_address
  attr_accessor :addresses

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
    self.temp_company_postcode = @transient_registration.temp_company_postcode

    look_up_addresses
    preselect_existing_address
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.addresses = add_or_replace_address(params[:temp_address])
    attributes = { addresses: addresses }

    super(attributes, params[:reg_identifier])
  end

  validates :addresses, presence: true

  private

  # Look up addresses based on the temp_company_postcode
  def look_up_addresses
    if temp_company_postcode.present?
      address_finder = AddressFinderService.new(temp_company_postcode)
      self.temp_addresses = address_finder.search_by_postcode
    else
      self.temp_addresses = []
    end
  end

  # If an address has already been assigned to the transient registration, pre-select it
  def preselect_existing_address
    return unless @transient_registration.addresses.present?
    current_address = @transient_registration.registered_address
    return unless current_address.uprn.present?
    selected_address = temp_addresses.detect { |address| address["uprn"] == current_address.uprn.to_s }
    self.temp_address = selected_address["uprn"] if selected_address.present?
  end

  def add_or_replace_address(selected_address_uprn)
    return if selected_address_uprn.blank?

    data = temp_addresses.detect { |address| address["uprn"] == selected_address_uprn }
    address = Address.create_from_os_places_data(data)
    address.assign_attributes(address_type: "REGISTERED")

    # Update the transient object's nested addresses, replacing any existing registered address
    updated_addresses = @transient_registration.addresses
    updated_addresses.delete(@transient_registration.registered_address) if @transient_registration.registered_address
    updated_addresses << address
    updated_addresses
  end
end
