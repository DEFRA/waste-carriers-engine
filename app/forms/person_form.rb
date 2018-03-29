class PersonForm < BaseForm
  attr_accessor :first_name, :last_name, :dob_day, :dob_month, :dob_year, :date_of_birth
  attr_accessor :new_person

  def initialize(transient_registration)
    super
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    self.position = params[:position] if position?
    process_date_fields(params)

    self.new_person = set_up_new_person
    self.date_of_birth = new_person.date_of_birth

    attributes = if fields_have_content?
                   { keyPeople: all_people }
                 else
                   {}
                 end

    super(attributes, params[:reg_identifier])
  end

  validates_with PersonValidator
  validate :old_enough?

  # Used to switch on usage of the :position attribute for validation and form-filling
  def position?
    false
  end

  def number_of_existing_people_in_type
    @transient_registration.send("#{person_type}_people".to_sym).count
  end

  def enough_people_in_type?
    return false if number_of_existing_people_in_type < minimum_people_in_type
    true
  end

  def can_only_have_one_person_in_type?
    return false unless maximum_people_in_type.present?
    maximum_people_in_type == 1
  end

  def fields_have_content?
    fields = [first_name, last_name, dob_day, dob_month, dob_year]
    fields.each do |field|
      return true if field.present? && field.to_s.length.positive?
    end
    false
  end

  # Methods which are called in this class but defined in subclasses
  # We should throw descriptive errors in case an additional subclass of PersonForm is ever added

  def maximum_people_in_type
    implemented_in_subclass
  end

  def minimum_people_in_type
    implemented_in_subclass
  end

  private

  def set_up_new_person
    KeyPerson.new(first_name: first_name,
                  last_name: last_name,
                  dob_day: dob_day,
                  dob_month: dob_month,
                  dob_year: dob_year,
                  person_type: person_type)
  end

  def all_people
    list_of_people_to_keep << new_person
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

  def old_enough?
    return false unless date_of_birth.present?

    return true if date_of_birth < age_cutoff_date

    errors.add(:date_of_birth, age_limit_error_message)
    false
  end

  def age_limit_error_message
    :age_limit
  end

  # Methods which are called in this class but defined in subclasses
  # We should throw descriptive errors in case an additional subclass of PersonForm is ever added

  def person_type
    implemented_in_subclass
  end

  def list_of_people_to_keep
    implemented_in_subclass
  end

  def age_cutoff_date
    implemented_in_subclass
  end

  def implemented_in_subclass
    raise NotImplementedError, "This #{self.class} cannot respond to:"
  end
end
