# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalLookupValidator < ActiveModel::Validator
    def validate(record)
      matching_registration = Registration.where(reg_identifier: record.temp_lookup_number).first

      return false unless valid_id?(record, matching_registration)

      registration_can_be_renewed?(record, matching_registration)
    end

    private

    def valid_id?(record, matching_registration)
      return true if matching_registration.present?

      record.errors.add(:temp_lookup_number, :invalid_format)
      false
    end

    def registration_can_be_renewed?(record, matching_registration)
      return true if matching_registration.can_start_renewal?

      record.errors.add(:temp_lookup_number, :cannot_be_renewed)
      false
    end
  end
end
