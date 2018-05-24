class CheckYourAnswersForm < BaseForm
  include CanLimitNumberOfMainPeople
  include CanLimitNumberOfRelevantPeople
  include CanNavigateFlexibly

  attr_accessor :business_type, :company_name, :company_no, :contact_address, :contact_address_display, :contact_email,
                :declared_convictions, :first_name, :last_name, :location, :main_people, :phone_number,
                :registered_address, :registered_address_display, :registration_type, :relevant_people, :tier

  def initialize(transient_registration)
    super
    self.business_type = @transient_registration.business_type
    self.company_name = @transient_registration.company_name
    self.company_no = @transient_registration.company_no
    self.contact_address = @transient_registration.contact_address
    self.contact_address_display = displayable_address(contact_address)
    self.contact_email = @transient_registration.contact_email
    self.declared_convictions = @transient_registration.declared_convictions
    self.first_name = @transient_registration.first_name
    self.last_name = @transient_registration.last_name
    self.location = @transient_registration.location
    self.main_people = @transient_registration.main_people
    self.phone_number = @transient_registration.phone_number
    self.registered_address = @transient_registration.registered_address
    self.registered_address_display = displayable_address(registered_address)
    self.registration_type = @transient_registration.registration_type
    self.relevant_people = @transient_registration.relevant_people
    self.tier = @transient_registration.tier

    valid?
  end

  def submit(params)
    attributes = {}

    super(attributes, params[:reg_identifier])
  end

  def registration_type_changed?
    @transient_registration.registration_type_changed?
  end

  def contact_name
    "#{first_name} #{last_name}"
  end

  validates :business_type, business_type: true
  validates :company_name, company_name: true
  validates :company_no, company_no: true
  validates :contact_address, address: true
  validates :contact_email, email: true
  validates :declared_convictions, boolean: true
  validates :first_name, :last_name, person_name: true
  validates :location, location: true
  validates :phone_number, phone_number: true
  validates :registered_address, address: true
  validates :registration_type, registration_type: true
  validate :should_be_renewed

  validates_with KeyPeopleValidator

  private

  def displayable_address(address)
    return [] unless address.present?
    # Get all the possible address lines, then remove the blank ones
    [address.address_line_1,
     address.address_line_2,
     address.address_line_3,
     address.address_line_4,
     address.town_city,
     address.postcode,
     address.country].reject
  end

  def should_be_renewed
    business_type_change_valid? && same_company_no?
  end

  def business_type_change_valid?
    return true if @transient_registration.business_type_change_valid?
    errors.add(:business_type, :invalid_change)
    false
  end

  def same_company_no?
    return true unless @transient_registration.company_no_changed?
    errors.add(:company_no, :changed)
    false
  end
end
