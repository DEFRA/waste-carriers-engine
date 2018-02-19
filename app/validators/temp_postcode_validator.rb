require "uk_postcode"

class TempPostcodeValidator < ActiveModel::Validator
  def validate(record)
    postcode_returns_results?(record) if value_is_present?(record) && value_uses_correct_format?(record)
  end

  private

  def value_is_present?(record)
    return true if record.temp_postcode.present?
    record.errors.add(:temp_postcode, :blank)
    false
  end

  def value_uses_correct_format?(record)
    return true if UKPostcode.parse(record.temp_postcode).full_valid?
    record.errors.add(:temp_postcode, :wrong_format)
    false
  end

  def postcode_returns_results?(record)
    return if record.transition_flag == :user_skips_to_manual_address
    address_finder = AddressFinderService.new(record.temp_postcode)
    case address_finder.search_by_postcode
    when :not_found
      record.errors.add(:temp_postcode, :no_results)
      false
    when :error
      record.transition_flag = :os_places_error
      true
    else
      true
    end
  end
end
