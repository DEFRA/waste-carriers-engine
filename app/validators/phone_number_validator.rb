class PhoneNumberValidator < ActiveModel::Validator
  def validate(record)
    return false unless field_is_present?(record)
    return false unless field_is_valid_length?(record)
    valid_format?(record)
  end

  private

  def field_is_present?(record)
    return true if record.phone_number.present?
    record.errors.add(:phone_number, :blank)
    false
  end

  def field_is_valid_length?(record)
    return true if record.phone_number.length < 16
    record.errors.add(:phone_number, :too_long)
    false
  end

  def valid_format?(record)
    return true if Phonelib.valid?(record.phone_number)
    record.errors.add(:phone_number, :invalid_format)
    false
  end
end
