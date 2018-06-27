class CompanyNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return false unless value_is_present?(record, attribute, value)
    value_is_not_too_long?(record, attribute, value)
  end

  private

  def value_is_present?(record, attribute, value)
    return true if value.present?
    record.errors[attribute] << error_message(record, attribute, "blank")
    false
  end

  def value_is_not_too_long?(record, attribute, value)
    return true if value.length < 256
    record.errors[attribute] << error_message(record, attribute, "too_long")
    false
  end

  def error_message(record, attribute, error)
    class_name = record.class.to_s.underscore
    I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
  end
end
