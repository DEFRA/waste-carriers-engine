# frozen_string_literal: true

module WasteCarriersEngine
  class RenewingRegistrationPermissionChecksService < BaseRegistrationPermissionChecksService

    private

    def all_checks_pass?
      transient_registration_is_valid? && user_has_permission? && can_be_renewed?
    end

    def user_has_permission?
      # user permission checks apply only to the back office
      return true unless WasteCarriersEngine.configuration.host_is_back_office?

      return true if transient_registration.from_magic_link
      return true if can?(:update, transient_registration)

      permission_check_result.needs_permissions!

      false
    end

    def can_be_renewed?
      return true if transient_registration.can_be_renewed?

      permission_check_result.unrenewable!

      false
    end
  end
end
