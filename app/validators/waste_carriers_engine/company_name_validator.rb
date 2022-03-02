# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyNameValidator < ActiveModel::EachValidator
    include CanAddValidationErrors

    def validate_each(record, attribute, value)
      return false unless value_is_present?(record, attribute, value)

      value_is_not_too_long?(record, attribute, value)
    end

    private

    def value_is_present?(record, attribute, value)
      return true if value.present?

      return true if attribute == :company_name && record.registered_company_name.present?

      add_validation_error(record, attribute, :blank)
      false
    end

    def value_is_not_too_long?(record, attribute, value)
      return true if value.nil? || value.length < 256

      add_validation_error(record, attribute, :too_long)
      false
    end
  end
end
