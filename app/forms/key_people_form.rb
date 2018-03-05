class KeyPeopleForm < BaseForm
  attr_accessor :business_type
  attr_accessor :first_name, :last_name, :dob_day, :dob_month, :dob_year, :key_person, :date_of_birth

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    process_date_fields(params)

    self.key_person = add_key_person
    self.date_of_birth = key_person.date_of_birth

    attributes = { keyPeople: [key_person] }

    super(attributes, params[:reg_identifier])
  end

  validates_with KeyPeopleValidator
  validate :old_enough?

  private

  # If we can make the date fields positive integers, save those integers
  # Otherwise, save as nil
  def process_date_fields(params)
    day = params[:dob_day].to_i
    month = params[:dob_month].to_i
    year = params[:dob_year].to_i

    self.dob_day = day if day.positive?
    self.dob_month = month if month.positive?
    self.dob_year = year if year.positive?
  end

  def add_key_person
    KeyPerson.new(first_name: first_name,
                  last_name: last_name,
                  dob_day: dob_day,
                  dob_month: dob_month,
                  dob_year: dob_year,
                  person_type: "key")
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
