module WasteCarriersEngine
  class AddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return false unless value_is_present?(record, attribute, value)
      format_matches_location?(record, attribute, value)
    end

    private

    def value_is_present?(record, attribute, value)
      return true if value.present?
      record.errors[attribute] << error_message(record, attribute, "blank")
      false
    end

    def format_matches_location?(record, attribute, value)
      if record.transient_registration.overseas?
        valid_overseas_address?(record, attribute, value)
      else
        valid_uk_address?(record, attribute, value)
      end
    end

    def valid_uk_address?(record, attribute, value)
      return true if value.address_mode == "address-results"
      return true if value.address_mode == "manual-uk"
      record.errors[attribute] << error_message(record, attribute, "should_be_uk")
      false
    end

    def valid_overseas_address?(record, attribute, value)
      return true if value.address_mode == "manual-foreign"
      record.errors[attribute] << error_message(record, attribute, "should_be_overseas")
      false
    end

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
