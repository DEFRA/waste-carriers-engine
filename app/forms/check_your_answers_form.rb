class CheckYourAnswersForm < BaseForm
  attr_accessor :business_type, :company_name, :company_no, :contact_address, :contact_email, :declared_convictions,
                :first_name, :last_name, :location, :main_people, :phone_number, :registered_address,
                :registration_type, :relevant_people, :tier

  def initialize(transient_registration)
    super
    self.business_type = @transient_registration.business_type
    self.company_name = @transient_registration.company_name
    self.company_no = @transient_registration.company_no
    self.contact_address = displayable_address(@transient_registration.contact_address)
    self.contact_email = @transient_registration.contact_email
    self.declared_convictions = boolean_to_string(@transient_registration.declared_convictions)
    self.first_name = @transient_registration.first_name
    self.last_name = @transient_registration.last_name
    self.location = @transient_registration.location
    self.main_people = @transient_registration.main_people
    self.phone_number = @transient_registration.phone_number
    self.registered_address = displayable_address(@transient_registration.registered_address)
    self.registration_type = @transient_registration.registration_type
    self.relevant_people = @transient_registration.relevant_people
    self.tier = @transient_registration.tier
  end

  def submit(params)
    attributes = {}

    super(attributes, params[:reg_identifier])
  end

  def contact_name
    "#{first_name} #{last_name}"
  end

  private

  def boolean_to_string(value)
    return "yes" if value
    "no"
  end

  def displayable_address(address)
    return [] unless address.present?
    # Get all the possible address lines, then remove the blank ones
    [address.house_number,
     address.address_line_1,
     address.address_line_2,
     address.address_line_3,
     address.address_line_4,
     address.town_city,
     address.postcode,
     address.country].reject
  end
end
