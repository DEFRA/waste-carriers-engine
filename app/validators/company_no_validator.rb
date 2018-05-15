class CompanyNoValidator < ActiveModel::EachValidator
  VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX = Regexp.new(/\A(\d{8,8}$)|([a-zA-Z]{2}\d{6}$)\z/i).freeze

  def validate_each(record, attribute, value)
    return false unless value_is_present?(record, attribute, value)
    return false unless format_is_valid?(record, attribute, value)
    validate_with_companies_house(record, attribute, value)
  end

  private

  def value_is_present?(record, attribute, value)
    return true if value.present?
    record.errors[attribute] << I18n.t("errors.messages.company_no.blank")
    false
  end

  def format_is_valid?(record, attribute, value)
    return true if value.match?(VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX)
    record.errors[attribute] << I18n.t("errors.messages.company_no.invalid_format")
    false
  end

  def validate_with_companies_house(record, attribute, value)
    case CompaniesHouseService.new(value).status
    when :active
      true
    when :inactive
      record.errors[attribute] << I18n.t("errors.messages.company_no.inactive")
    when :not_found
      record.errors[attribute] << I18n.t("errors.messages.company_no.not_found")
    when :error
      record.errors[attribute] << I18n.t("errors.messages.company_no.error")
    end
  end
end
