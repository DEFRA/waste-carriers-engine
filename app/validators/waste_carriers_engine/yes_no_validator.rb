# frozen_string_literal: true

module WasteCarriersEngine
  class YesNoValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      valid_values = %w[yes no]
      return true if valid_values.include?(value)

      record.errors[attribute] << error_message(record, attribute, "inclusion")
      false
    end

    private

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
