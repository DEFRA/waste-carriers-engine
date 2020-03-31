# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalLookupValidator < ActiveModel::Validator
    def validate(record)
      registration = Registration.where(reg_identifier: record.temp_lookup_number).first

      return false unless valid_id?(record, registration)
      return false unless registration_is_upper_tier?(record, registration)
      return false unless renewable_status?(record, registration)

      renewable_date?(record, registration)
    end

    private

    def valid_id?(record, registration)
      return true if registration.present?

      record.errors.add(:temp_lookup_number, :no_match)
      false
    end

    def registration_is_upper_tier?(record, registration)
      return true if registration.upper_tier?

      record.errors.add(:temp_lookup_number, :lower_tier)
      false
    end

    def renewable_status?(record, registration)
      return true if registration.active?
      return true if registration.expired?

      record.errors.add(:temp_lookup_number, :unrenewable_status)
      false
    end

    def renewable_date?(record, registration)
      check_service = ExpiryCheckService.new(registration)

      if check_service.expired?
        registration_in_expiry_grace_window?(record, check_service)
      else
        registration_in_renewal_window?(record, check_service)
      end
    end

    def registration_in_expiry_grace_window?(record, check_service)
      return true if check_service.in_expiry_grace_window?

      record.errors.add(:temp_lookup_number, :expired)
      false
    end

    def registration_in_renewal_window?(record, check_service)
      return true if check_service.in_renewal_window?

      renewable_date = check_service.date_can_renew_from
      record.errors.add(:temp_lookup_number, :not_yet_renewable, date: renewable_date)
      false
    end
  end
end
