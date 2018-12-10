# frozen_string_literal: true

module WasteCarriersEngine
  class PhoneNumberValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return false unless field_is_present?(record, attribute, value)
      return false unless field_is_valid_length?(record, attribute, value)

      valid_format?(record, attribute, value)
    end

    private

    def field_is_present?(record, attribute, value)
      return true if value.present?

      record.errors[attribute] << error_message(record, attribute, "blank")
      false
    end

    def field_is_valid_length?(record, attribute, value)
      return true if value.length < 16

      record.errors[attribute] << error_message(record, attribute, "too_long")
      false
    end

    def valid_format?(record, attribute, value)
      return true if Phonelib.valid?(value)

      record.errors[attribute] << error_message(record, attribute, "invalid_format")
      false
    end

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
