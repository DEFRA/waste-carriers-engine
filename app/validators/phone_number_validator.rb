class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return false unless field_is_present?(record, attribute, value)
    return false unless field_is_valid_length?(record, attribute, value)
    valid_format?(record, attribute, value)
  end

  private

  def field_is_present?(record, attribute, value)
    return true if value.present?
    record.errors[attribute] << I18n.t("errors.messages.phone_number.blank")
    false
  end

  def field_is_valid_length?(record, attribute, value)
    return true if value.length < 16
    record.errors[attribute] << I18n.t("errors.messages.phone_number.too_long")
    false
  end

  def valid_format?(record, attribute, value)
    return true if Phonelib.valid?(value)
    record.errors[attribute] << I18n.t("errors.messages.phone_number.invalid_format")
    false
  end
end
