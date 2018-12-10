# frozen_string_literal: true

module WasteCarriersEngine
  class LocationValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      valid_locations = %w[england
                           northern_ireland
                           scotland
                           wales
                           overseas]
      return true if value.present? && valid_locations.include?(value)

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
