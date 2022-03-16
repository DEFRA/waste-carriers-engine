# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyNameValidator < ActiveModel::EachValidator
    include CanAddValidationErrors

    def validate_each(record, attribute, value)
      if attribute == :company_name
        return false unless valid_company_name?(record, attribute, value)
      else
        return false unless value_is_present?(record, attribute, value)
      end

      value_is_not_too_long?(record, attribute, value)
    end

    private

    def value_is_present?(record, attribute, value)
      return true if value.present?

      add_validation_error(record, attribute, :blank)
      false
    end

    def value_is_not_too_long?(record, attribute, value)
      return true if value.nil? || value.length < 256

      add_validation_error(record, attribute, :too_long)
      false
    end

    def valid_company_name?(record, attribute, value)
      if (%w[limitedCompany limitedLiabilityPartnership].include? record.business_type) &&
         !record.registered_company_name.present?
        return value_is_present?(record, attribute, value)
      end

      true
    end
  end
end
