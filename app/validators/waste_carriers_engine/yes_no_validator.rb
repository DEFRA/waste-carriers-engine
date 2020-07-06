# frozen_string_literal: true

module WasteCarriersEngine
  class YesNoValidator < ActiveModel::EachValidator
    include CanAddValidationErrors

    def validate_each(record, attribute, value)
      valid_values = %w[yes no]
      return true if valid_values.include?(value)

      add_validation_error(record, attribute, :inclusion)
      false
    end
  end
end
