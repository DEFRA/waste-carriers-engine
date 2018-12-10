# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyNoValidator < ActiveModel::EachValidator
    VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX = Regexp.new(/\A(\d{8,8}$)|([a-zA-Z]{2}\d{6}$)\z/i).freeze

    def validate_each(record, attribute, value)
      valid_company_no?(record, attribute, value) if company_no_required?(record)
    end

    private

    def company_no_required?(record)
      record.transient_registration.company_no_required?
    end

    def valid_company_no?(record, attribute, value)
      return false unless value_is_present?(record, attribute, value)
      return false unless format_is_valid?(record, attribute, value)

      validate_with_companies_house(record, attribute, value)
    end

    def value_is_present?(record, attribute, value)
      return true if value.present?

      record.errors[attribute] << error_message(record, attribute, "blank")
      false
    end

    def format_is_valid?(record, attribute, value)
      return true if value.match?(VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX)

      record.errors[attribute] << error_message(record, attribute, "invalid_format")
      false
    end

    def validate_with_companies_house(record, attribute, value)
      case CompaniesHouseService.new(value).status
      when :active
        true
      when :inactive
        record.errors[attribute] << error_message(record, attribute, "inactive")
      when :not_found
        record.errors[attribute] << error_message(record, attribute, "not_found")
      when :error
        record.errors[attribute] << error_message(record, attribute, "error")
      end
    end

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
