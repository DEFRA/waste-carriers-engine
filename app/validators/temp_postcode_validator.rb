class TempPostcodeValidator < ActiveModel::Validator
  def validate(record)
    postcode_returns_results?(record) if value_is_present?(record) && value_is_valid_length?(record)
  end

  private

  def value_is_present?(record)
    return true if record.temp_postcode.present?
    record.errors.add(:temp_postcode, :blank)
    false
  end

  def value_is_valid_length?(record)
    return true if record.temp_postcode.length < 11
    record.errors.add(:temp_postcode, :too_long)
    false
  end

  def postcode_returns_results?(record)
    address_finder = AddressFinderService.new(record.temp_postcode)
    case address_finder.search_by_postcode
    when :not_found
      record.errors.add(:temp_postcode, :no_results)
      false
    when :error
      record.errors.add(:temp_postcode, :os_places_error)
      false
    else
      true
    end
  end
end
