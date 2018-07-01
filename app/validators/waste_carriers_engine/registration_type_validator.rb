module WasteCarriersEngine
  class RegistrationTypeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      valid_types = %w[carrier_dealer
                       broker_dealer
                       carrier_broker_dealer]
      return true if value.present? && valid_types.include?(value)
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
