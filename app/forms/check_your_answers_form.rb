class CheckYourAnswersForm < BaseForm
  attr_accessor :business_type, :company_name, :company_no, :contact_address, :contact_email, :declared_convictions,
                :contact_name, :location, :main_people, :phone_number, :registered_address, :registration_type,
                :relevant_people, :tier

  def initialize(transient_registration)
    super
    self.business_type = @transient_registration.business_type
    self.company_name = @transient_registration.company_name
    self.company_no = @transient_registration.company_no
    self.contact_name = format_contact_name
    self.contact_address = displayable_address(@transient_registration.contact_address)
    self.contact_email = @transient_registration.contact_email
    self.declared_convictions = @transient_registration.declared_convictions
    self.location = @transient_registration.location
    self.main_people = @transient_registration.main_people
    self.phone_number = @transient_registration.phone_number
    self.registered_address = displayable_address(@transient_registration.registered_address)
    self.registration_type = @transient_registration.registration_type
    self.relevant_people = @transient_registration.relevant_people
    self.tier = @transient_registration.tier

    required_fields_filled_in?
  end

  def submit(params)
    attributes = {}

    super(attributes, params[:reg_identifier])
  end

  def registration_type_changed?
    @transient_registration.registration_type_changed?
  end

  def required_fields_filled_in?
    valid = true
    required_fields.each do |field|
      # Field must be present or equal to 'false' to be valid
      # This is to allow for booleans - false is fine, nil is not
      next if send(field).present? || send(field).to_s == "false"
      errors.add(field, :missing)
      valid = false
    end
    valid
  end

  private

  # These are fields which must have been filled in by this point for this to be a valid renewal
  def required_fields
    fields = %i[business_type
                company_name
                contact_name
                contact_address
                contact_email
                declared_convictions
                location
                main_people
                phone_number
                registered_address
                registration_type
                tier]
    fields << :company_no if company_no_required?
    fields << :relevant_people if relevant_people_required?

    fields
  end

  def company_no_required?
    return true if business_type == "limitedCompany"
    return true if business_type == "limitedLiabilityPartnership"
    false
  end

  def relevant_people_required?
    declared_convictions
  end

  def format_contact_name
    "#{@transient_registration.first_name} #{@transient_registration.last_name}"
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
