# frozen_string_literal: true

module WasteCarriersEngine
  class PersonForm < ::WasteCarriersEngine::BaseForm
    attr_accessor :first_name, :last_name, :position, :dob_day, :dob_month, :dob_year, :dob, :new_person

    validate :old_enough?

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.first_name = params[:first_name]
      self.last_name = params[:last_name]
      self.position = params[:position] if position?
      process_date_fields(params)

      self.new_person = set_up_new_person
      self.dob = new_person.dob

      attributes = if fields_have_content?
                     { key_people: all_people }
                   else
                     {}
                   end

      super(attributes)
    end

    # Used to switch on usage of the :position attribute for validation and form-filling
    def position?
      false
    end

    def fields_have_content?
      fields = [first_name, last_name, dob_day, dob_month, dob_year]
      fields << position if position?
      fields.each do |field|
        return true if field.present? && field.to_s.length.positive?
      end
      false
    end

    # Methods which are called in this class but defined in subclasses
    # We should throw descriptive errors in case an additional subclass of PersonForm is ever added

    def person_type
      implemented_in_subclass
    end

    private

    def set_up_new_person
      person = KeyPerson.new(first_name: first_name,
                             last_name: last_name,
                             dob_day: dob_day,
                             dob_month: dob_month,
                             dob_year: dob_year,
                             person_type: person_type.upcase)
      person.position = position if position?

      person
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
      integer_value if integer_value.positive?
    end

    def old_enough?
      return false unless dob.present?

      return true if dob < age_cutoff_date

      errors.add(:dob, age_limit_error_message)
      false
    end

    def age_limit_error_message
      :age_limit
    end

    # Methods which are called in this class but defined in subclasses
    # We should throw descriptive errors in case an additional subclass of PersonForm is ever added

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
end
