class CompanyNoValidator < ActiveModel::Validator
  VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX = Regexp.new(/\A(\d{8,8}$)|([a-zA-Z]{2}\d{6}$)\z/i).freeze

  def validate(record)
    validate_with_companies_house(record) if format_is_valid?(record)
  end

  private

  def format_is_valid?(record)
    return true if record.company_no.match?(VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX)
    record.errors.add(:company_no, :invalid_format)
    false
  end

  def validate_with_companies_house(record)
    case CompaniesHouseService.new(record.company_no).status
    when :active
      true
    when :inactive
      record.errors.add(:company_no, :inactive)
    when :not_found
      record.errors.add(:company_no, :not_found)
    when :error
      record.errors.add(:company_no, :error)
    end
  end
end
