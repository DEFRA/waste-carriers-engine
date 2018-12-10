# frozen_string_literal: true

module WasteCarriersEngine
  class MatchingEmailValidator < ActiveModel::EachValidator
    # Expects to be passed an attribute on the same record to confirm against,
    # for example: validates :confirmed_email, matching_email: { compare_to: :contact_email }
    def validate_each(record, attribute, value)
      email_address_to_confirm = record.send(options[:compare_to])
      return true if value == email_address_to_confirm

      record.errors[attribute] << error_message(record, attribute, "does_not_match")
      false
    end

    private

    def error_message(record, attribute, error)
      class_name = record.class.to_s.underscore
      I18n.t("activemodel.errors.models.#{class_name}.attributes.#{attribute}.#{error}")
    end
  end
end
