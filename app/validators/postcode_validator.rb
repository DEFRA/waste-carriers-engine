require "uk_postcode"

class PostcodeValidator < ActiveModel::Validator
  def validate(record)
    return unless options[:fields].any?
    options[:fields].each do |field|
      validate_postcode_field(record, field)
    end
  end

  private

  def validate_postcode_field(record, field)
    return unless value_is_present?(record, field)
    return unless value_uses_correct_format?(record, field)
    postcode_returns_results?(record, field)
  end

  def value_is_present?(record, field)
    return true if record.send(field).present?
    record.errors.add(field, :blank)
    false
  end

  def value_uses_correct_format?(record, field)
    return true if UKPostcode.parse(record.send(field)).full_valid?
    record.errors.add(field, :wrong_format)
    false
  end

  def postcode_returns_results?(record, field)
    address_finder = AddressFinderService.new(record.send(field))
    case address_finder.search_by_postcode
    when :not_found
      record.errors.add(field, :no_results)
      false
    when :error
      record.transient_registration.temp_os_places_error = true
      true
    else
      true
    end
  end
end
