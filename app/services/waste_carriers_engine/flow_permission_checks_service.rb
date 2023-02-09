# frozen_string_literal: true

# This is the main servise for permission checks on both user permissions and
# registration status used in the `FormController`.
# This will be used to run the correct checks based on the type of flow / transient object the user is dealing with.
module WasteCarriersEngine
  class FlowPermissionChecksService < BaseService
    class MissingFlowPermissionChecksService < StandardError; end

    attr_reader :transient_registration, :user

    def run(transient_registration:, user:)
      @transient_registration = transient_registration
      @user = user

      run_flow_setup_checks
    end

    private

    def run_flow_setup_checks
      params = { transient_registration: transient_registration, user: user }

      case transient_registration
      when RenewingRegistration
        RenewingRegistrationPermissionChecksService.run(params)
      when EditRegistration
        EditRegistrationPermissionChecksService.run(params)
      when OrderCopyCardsRegistration
        OrderCopyCardsRegistrationPermissionChecksService.run(params)
      when CeasedOrRevokedRegistration
        CeasedOrRevokedRegistrationPermissionChecksService.run(params)
      when NewRegistration, DeregisteringRegistration
        BlankPermissionCheckService.run(params)
      else
        raise MissingFlowPermissionChecksService, "No permission service found for #{transient_registration.class}"
      end
    end
  end
end
