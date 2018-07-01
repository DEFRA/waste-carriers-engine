require "validates_email_format_of"

module WasteCarriersEngine
  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return false unless value_is_present?(record, attribute, value)
      valid_format?(record, attribute, value)
    end

    private

    def value_is_present?(record, attribute, value)
      return true if value.present?
      record.errors[attribute] << error_message(record, attribute, "blank")
      false
    end

    def valid_format?(record, attribute, value)
      # validate_email_format returns nil if the validation passes
      return true unless ValidatesEmailFormatOf.validate_email_format(value)
      record.errors[attribute] << error_message(record, attribute, "invalid_format")
      false
    end

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
