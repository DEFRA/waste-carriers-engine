# frozen_string_literal: true

module WasteCarriersEngine
  class BusinessTypeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if record.transient_registration.overseas?

      valid_business_type?(record, attribute, value)
    end

    private

    def valid_business_type?(record, attribute, value)
      valid_business_types = %w[charity
                                limitedCompany
                                limitedLiabilityPartnership
                                localAuthority
                                partnership
                                soleTrader]

      return true if value.present? && valid_business_types.include?(value)

      record.errors[attribute] << error_message(record, attribute, "inclusion")
      false
    end

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
