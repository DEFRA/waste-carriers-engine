# frozen_string_literal: true

module WasteCarriersEngine
  class PersonNameValidator < ActiveModel::EachValidator
    include CanAddValidationErrors

    def validate_each(record, attribute, value)
      return false unless value_is_present?(record, attribute, value)

      value_is_not_too_long?(record, attribute, value)
      value_has_no_invalid_characters?(record, attribute, value)
    end

    private

    def value_is_present?(record, attribute, value)
      return true if value.present?

      add_validation_error(record, attribute, :blank)
      false
    end

    def value_is_not_too_long?(record, attribute, value)
      return true if value.length < 71

      add_validation_error(record, attribute, :too_long)
      false
    end

    def value_has_no_invalid_characters?(record, attribute, value)
      # Name fields must contain only letters, spaces, commas, full stops, hyphens and apostrophes
      return true if value.match?(/\A[-a-z\s,.']+\z/i)

      add_validation_error(record, attribute, :invalid)
      false
    end
  end
end
