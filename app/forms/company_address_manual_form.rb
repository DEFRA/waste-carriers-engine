class CompanyAddressManualForm < BaseForm
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

    # Prefill the existing address unless the temp_postcode has changed from the saved postcode
    # Otherwise, just fill in the temp_postcode
    saved_address_still_valid? ? prefill_existing_address : self.postcode = @transient_registration.temp_postcode
  end

  def submit(params)
    # Strip out whitespace from start and end
    params.each { |_key, value| value.strip! }
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
  validates :country, length: { maximum: 255 }

  def overseas?
    business_type == "overseas"
  end

  private

  def saved_address_still_valid?
    return true if overseas?
    return false unless @transient_registration.registered_address
    return true if @transient_registration.temp_postcode == @transient_registration.registered_address.postcode
    false
  end

  def prefill_existing_address
    return unless @transient_registration.registered_address
    self.house_number = @transient_registration.registered_address.house_number
    self.address_line_1 = @transient_registration.registered_address.address_line_1
    self.address_line_2 = @transient_registration.registered_address.address_line_2
    self.town_city = @transient_registration.registered_address.town_city
    self.postcode = @transient_registration.registered_address.postcode
    self.country = @transient_registration.registered_address.country
  end

  def add_or_replace_address(params)
    address = Address.create_from_manual_entry(params, business_type)
    address.assign_attributes(address_type: "REGISTERED")

    # Update the transient object's nested addresses, replacing any existing registered address
    updated_addresses = @transient_registration.addresses
    updated_addresses.delete(@transient_registration.registered_address) if @transient_registration.registered_address
    updated_addresses << address
    updated_addresses
  end
end
