# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationTypeValidator < ActiveModel::EachValidator
    include CanAddValidationErrors

    def validate_each(record, attribute, value)
      valid_types = %w[carrier_dealer
                       broker_dealer
                       carrier_broker_dealer]
      return true if value.present? && valid_types.include?(value)

      add_validation_error(record, attribute, :inclusion)
      false
    end
  end
end
