class CompanyNoValidator < ActiveModel::Validator
  def validate(record)
    case CompaniesHouseCaller.new(record.company_no).status
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
