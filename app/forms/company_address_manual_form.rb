class CompanyAddressManualForm < BaseForm
  attr_accessor :business_type
  attr_accessor :addresses
  # We pass the following attributes in to create a new Address
  attr_accessor :house_number, :address_line_1, :address_line_2, :town_city, :postcode, :country

  def initialize(transient_registration)
    super
    # We use this for the correct microcopy and to determine what fields to show
    self.business_type = @transient_registration.business_type
    # TODO: Uncomment this once other PR is merged in
    # if @transient_registration.temp_postcode.present?
    #   self.postcode = @transient_registration.temp_postcode
    # else
    #   self.postcode = nil
    # end
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.addresses = [add_address(params)]
    attributes = { addresses: addresses }

    super(attributes, params[:reg_identifier])
  end

  validates_presence_of :country, if: :overseas?

  def overseas?
    business_type == "overseas"
  end

  private

  def add_address(params)
    address = Address.create_from_manual_entry(params, business_type)
    address.assign_attributes(address_type: "REGISTERED")
    address
  end
end
