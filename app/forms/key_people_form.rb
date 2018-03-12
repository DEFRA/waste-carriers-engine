class KeyPeopleForm < BaseForm
  attr_accessor :business_type
  attr_accessor :first_name, :last_name, :dob_day, :dob_month, :dob_year, :key_person, :date_of_birth

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type

    # If there's only one key person, we can pre-fill the fields so users can easily edit them
    prefill_form if can_only_have_one_key_person? && @transient_registration.keyPeople.present?
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    process_date_fields(params)

    self.key_person = add_key_person
    self.date_of_birth = key_person.date_of_birth

    attributes = if fields_have_content?
                   { keyPeople: all_key_people }
                 else
                   {}
                 end

    super(attributes, params[:reg_identifier])
  end

  validates_with KeyPeopleValidator
  validate :old_enough?

  def maximum_key_people
    return unless business_type.present?
    key_people_limits[business_type.to_sym][:maximum]
  end

  def minimum_key_people
    # Business type should always be set, but use 1 as the default, just in case
    return 1 unless business_type.present?
    key_people_limits[business_type.to_sym][:minimum]
  end

  def number_of_existing_key_people
    @transient_registration.keyPeople.count
  end

  def can_only_have_one_key_person?
    return false unless maximum_key_people.present?
    maximum_key_people == 1
  end

  def enough_key_people?
    return false if number_of_existing_key_people < minimum_key_people
    true
  end

  def fields_have_content?
    fields = [first_name, last_name, dob_day, dob_month, dob_year]
    fields.each do |field|
      return true if field.present? && field.to_s.length.positive?
    end
    false
  end

  private

  def prefill_form
    self.first_name = @transient_registration.keyPeople.first.first_name
    self.last_name = @transient_registration.keyPeople.first.last_name
    self.dob_day = @transient_registration.keyPeople.first.dob_day
    self.dob_month = @transient_registration.keyPeople.first.dob_month
    self.dob_year = @transient_registration.keyPeople.first.dob_year
  end

  def process_date_fields(params)
    self.dob_day = format_date_field_value(params[:dob_day])
    self.dob_month = format_date_field_value(params[:dob_month])
    self.dob_year = format_date_field_value(params[:dob_year])
  end

  # If we can make the date fields positive integers, use those integers
  # Otherwise, return nil
  def format_date_field_value(value)
    # If this isn't a valid integer, .to_i returns 0
    integer_value = value.to_i
    return integer_value if integer_value.positive?
  end

  def add_key_person
    KeyPerson.new(first_name: first_name,
                  last_name: last_name,
                  dob_day: dob_day,
                  dob_month: dob_month,
                  dob_year: dob_year,
                  person_type: "key")
  end

  def all_key_people
    # If there's only one key person allowed, just replace existing data
    return [key_person] if can_only_have_one_key_person?

    existing_key_people = []
    # Adding the new key person directly to @transient_registration.keyPeople immediately updates the object,
    # regardless of validation. So instead we copy the existing key people into a new array and modify that.
    @transient_registration.keyPeople.each do |person|
      existing_key_people << person
    end
    existing_key_people << key_person
  end

  def key_people_limits
    {
      limitedCompany: { minimum: 1, maximum: nil },
      limitedLiabilityPartnership: { minimum: 1, maximum: nil },
      localAuthority: { minimum: 1, maximum: nil },
      overseas: { minimum: 1, maximum: nil },
      partnership: { minimum: 2, maximum: nil },
      soleTrader: { minimum: 1, maximum: 1 }
    }
  end

  def old_enough?
    return false unless date_of_birth.present?

    age_limits = {
      limitedCompany: 16.years,
      limitedLiabilityPartnership: 17.years,
      localAuthority: 17.years,
      overseas: 17.years,
      partnership: 17.years,
      soleTrader: 17.years
    }
    age_cutoff_date = (Date.today - age_limits[business_type.to_sym]) + 1.day

    return true if date_of_birth < age_cutoff_date

    error_message = "age_limit_#{business_type}".to_sym
    errors.add(:date_of_birth, error_message)
    false
  end
end
