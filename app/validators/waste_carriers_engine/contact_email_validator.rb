# frozen_string_literal: true

module WasteCarriersEngine
  class ContactEmailValidator < ActiveModel::EachValidator
    include CanAddValidationErrors

    def validate(record)
      if WasteCarriersEngine.configuration.host_is_back_office? && record.no_contact_email == "1"
        if record.contact_email.present?
          add_validation_error(record, :no_contact_email, :not_blank)
          return false
        end

        return true
      end

      if record.confirmed_email != record.contact_email
        add_validation_error(record, :confirmed_email, :does_not_match)
        return false
      end

      DefraRuby::Validators::EmailValidator.new(attributes: [:contact_email]).validate(record)
    end
  end
end