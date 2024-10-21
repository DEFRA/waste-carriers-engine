# frozen_string_literal: true

module WasteCarriersEngine
  class RenewingRegistrationPermissionChecksService < BaseRegistrationPermissionChecksService

    private

    def all_checks_pass?
      transient_registration_is_valid? && can_be_renewed?
    end

    def can_be_renewed?
      return true if transient_registration.can_be_renewed?

      permission_check_result.unrenewable!

      false
    end
  end
end
