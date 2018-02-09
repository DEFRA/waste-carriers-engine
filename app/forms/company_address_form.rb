class CompanyAddressForm < BaseForm
  attr_accessor :business_type
  attr_accessor :temp_postcode
  attr_accessor :temp_addresses
  attr_accessor :address
  attr_accessor :addresses

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
    self.temp_postcode = @transient_registration.temp_postcode

    return unless temp_postcode.present?
    address_finder = AddressFinderService.new(temp_postcode)
    self.temp_addresses = address_finder.search_by_postcode
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.addresses = [add_address(params[:address])].compact
    attributes = { addresses: addresses }

    super(attributes, params[:reg_identifier])
  end

  validates :addresses, presence: true

  private

  def add_address(selected_address_uprn)
    return if selected_address_uprn.blank?

    data = temp_addresses.detect { |address| address["uprn"] == selected_address_uprn }
    address = Address.create_from_os_places_data(data)
    address.assign_attributes(address_type: "REGISTERED")
  end
end
