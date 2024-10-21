# frozen_string_literal: true

module WasteCarriersEngine
  class BaseRegistrationPermissionChecksService < BaseService
    include CanAddDebugLogging

    delegate :registration, to: :transient_registration

    attr_reader :transient_registration, :permission_check_result

    def run(transient_registration:)
      @transient_registration = transient_registration
      @permission_check_result = PermissionChecksResult.new

      permission_check_result.pass! if all_checks_pass?

      permission_check_result
    end

    private

    def all_checks_pass?
      raise NotImplementedError
    end

    def transient_registration_is_valid?
      return true if transient_registration.valid?

      permission_check_result.invalid!

      false
    end
  end
end
