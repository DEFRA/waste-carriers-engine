# frozen_string_literal: true

module WasteCarriersEngine
  class RegIdentifierValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      valid_format?(record, attribute, value)
      matches_existing_registration?(record, attribute, value)
    end

    private

    def valid_format?(record, attribute, value)
      # Make sure the format of the reg_identifier is valid to prevent injection
      # Format should be CBDU or CBDL, followed by at least one digit
      return true if value.present? && value.match?(/^CBD[U|L][0-9]+$/)

      record.errors.add(attribute,
                        :invalid_format,
                        message: error_message(record, attribute, "invalid_format"))
      false
    end

    def matches_existing_registration?(record, attribute, value)
      return true if Registration.where(reg_identifier: value).exists?

      record.errors.add(attribute,
                        :no_registration,
                        message: error_message(record, attribute, "no_registration"))
      false
    end

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
