class ConvictionDetailsForm < BaseForm
  attr_accessor :first_name, :last_name, :position, :dob_day, :dob_month, :dob_year, :relevant_person, :date_of_birth

  def initialize(transient_registration)
    super
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    self.position = params[:positon]
    process_date_fields(params)

    self.relevant_person = add_relevant_person
    self.date_of_birth = relevant_person.date_of_birth

    attributes = if fields_have_content?
                   { keyPeople: all_people }
                 else
                   {}
                 end

    super(attributes, params[:reg_identifier])
  end

  validates_with KeyPeopleValidator
  validate :old_enough?

  def maximum_key_people
    nil
  end

  def minimum_key_people
    1
  end

  def number_of_existing_key_people
    @transient_registration.relevant_conviction_people.count
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

  def add_relevant_person
    KeyPerson.new(first_name: first_name,
                  last_name: last_name,
                  position: position,
                  dob_day: dob_day,
                  dob_month: dob_month,
                  dob_year: dob_year,
                  person_type: "relevant")
  end

  def all_people
    list_of_people_to_keep << relevant_person
  end

  # Adding the new person directly to @transient_registration.keyPeople immediately updates the object,
  # regardless of validation. So instead we copy all existing people into a new array and modify that.
  def list_of_people_to_keep
    people = []

    @transient_registration.keyPeople.each do |person|
      # We need to copy the person before adding to the array to avoid a 'conflicting modifications' Mongo error (10151)
      people << person.clone
    end

    people
  end

  def old_enough?
    return false unless date_of_birth.present?

    age_cutoff_date = (Date.today - 17.years) + 1.day

    return true if date_of_birth < age_cutoff_date

    error_message = "age_limit".to_sym
    errors.add(:date_of_birth, error_message)
    false
  end
end
