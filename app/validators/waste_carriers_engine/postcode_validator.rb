# frozen_string_literal: true

require "uk_postcode"

module WasteCarriersEngine
  class PostcodeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless value_is_present?(record, attribute, value)
      return unless value_uses_correct_format?(record, attribute, value)

      postcode_returns_results?(record, attribute, value)
    end

    private

    def value_is_present?(record, attribute, value)
      return true if value.present?

      record.errors[attribute] << error_message(record, attribute, "blank")
      false
    end

    def value_uses_correct_format?(record, attribute, value)
      return true if UKPostcode.parse(value).full_valid?

      record.errors[attribute] << error_message(record, attribute, "wrong_format")
      false
    end

    def postcode_returns_results?(record, attribute, value)
      response = AddressLookupService.run(value)

      return true if response.successful?

      if response.error.is_a?(DefraRuby::Address::NoMatchError)
        record.errors[attribute] << error_message(record, attribute, "no_results")
        false
      else
        record.transient_registration.temp_os_places_error = true
        true
      end
    end

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
