# frozen_string_literal: true

module WasteCarriersEngine
  class PersonValidator < ActiveModel::Validator
    def validate(record)
      if options[:validate_fields] || record.fields_have_content?
        validate_individual_fields(record)
      else
        validate_number_of_people(record)
      end
    end

    private

    def validate_individual_fields(record)
      validate_first_name(record)
      validate_last_name(record)
      validate_position(record) if record.position?
      DateOfBirthValidator.new(validate_fields: false).validate(record)
    end

    def validate_number_of_people(_record)
      implemented_in_subclass
    end

    def validate_first_name(record)
      return unless field_is_present?(record, :first_name)

      field_content_is_valid?(record, :first_name, 35)
    end

    def validate_last_name(record)
      return unless field_is_present?(record, :last_name)

      field_content_is_valid?(record, :last_name, 35)
    end

    def validate_position(record)
      return unless field_is_present?(record, :position)

      field_content_is_valid?(record, :position, 35)
    end

    def field_is_present?(record, field)
      return true if record.send(field).present?

      record.errors.add(field, :blank)
      false
    end

    def field_content_is_valid?(record, field, length)
      field_is_not_too_long?(record, field, length)
      field_has_no_invalid_characters?(record, field)
    end

    def field_is_not_too_long?(record, field, length)
      return true if record.send(field).length < length

      record.errors.add(field, :too_long)
      false
    end

    def field_has_no_invalid_characters?(record, field)
      # Name fields must contain only letters, spaces, commas, full stops, hyphens and apostrophes
      return true if record.send(field).match?(/\A[-a-z\s,.']+\z/i)

      record.errors.add(field, :invalid)
      false
    end

    def implemented_in_subclass
      raise NotImplementedError, "This #{self.class} cannot respond to:"
    end
  end
end
