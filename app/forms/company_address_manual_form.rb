class CompanyAddressManualForm < BaseForm
  attr_accessor :business_type
  attr_accessor :addresses
  # We pass the following attributes in to create a new Address
  attr_accessor :house_number, :address_line_1, :address_line_2, :town_city, :postcode, :country

  def initialize(transient_registration)
    super
    # We use this for the correct microcopy and to determine what fields to show
    self.business_type = @transient_registration.business_type
    prefill_existing_address
    # TODO: Uncomment this once other PR is merged in
    # if @transient_registration.temp_postcode.present?
    #   self.postcode = @transient_registration.temp_postcode
    # else
    #   self.postcode = nil
    # end
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
    attributes = { addresses: [add_address(params)] }

    super(attributes, params[:reg_identifier])
  end

  validates :house_number, presence: true, length: { maximum: 200 }
  validates :address_line_1, presence: true, length: { maximum: 160 }
  validates :address_line_2, length: { maximum: 70 }
  validates :town_city, presence: true, length: { maximum: 30 }
  validates :country, presence: true, if: :overseas?

  def overseas?
    business_type == "overseas"
  end

  private

  def prefill_existing_address
    return unless @transient_registration.registered_address
    self.house_number = @transient_registration.registered_address.house_number
    self.address_line_1 = @transient_registration.registered_address.address_line_1
    self.address_line_2 = @transient_registration.registered_address.address_line_2
    self.town_city = @transient_registration.registered_address.town_city
    self.postcode = @transient_registration.registered_address.postcode
    self.country = @transient_registration.registered_address.country
  end

  def add_address(params)
    address = Address.create_from_manual_entry(params, business_type)
    address.assign_attributes(address_type: "REGISTERED")
    address
  end
end
