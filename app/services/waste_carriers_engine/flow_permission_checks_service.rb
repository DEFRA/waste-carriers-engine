# frozen_string_literal: true

# This is the main servise for permission checks on both user permissions and
# registration status used in the `FormController`.
# This will be used to run the correct checks based on the type of flow / transient object the user is dealing with.
module WasteCarriersEngine
  class FlowPermissionChecksService < BaseService
    class MissingFlowPermissionChecksService < StandardError; end

    attr_reader :transient_registration, :user

    def run(transient_registration:, user: nil)
      @transient_registration = transient_registration
      @user = user

      run_flow_setup_checks
    end

    private

    def run_flow_setup_checks
      params = { transient_registration: transient_registration, user: user }

      case transient_registration
      when NewRegistration, DeregisteringRegistration
        BlankPermissionCheckService.run(params)
      else
        # For transient_registration class Xyz, run XyzPermissionChecksService:
        transient_registration_classname = transient_registration.class.to_s.split("::").last
        permission_checks_class = "WasteCarriersEngine::#{transient_registration_classname}PermissionChecksService"
        Object.const_get(permission_checks_class).send(:run, params)
      end
    rescue NameError => e
      Rails.logger.error "Error trying to run #{permission_checks_class}: #{e}"
      Airbrake.notify e, message: "Error trying to run #{permission_checks_class}"
      raise MissingFlowPermissionChecksService, "No permission service found for #{transient_registration.class}"
    end
  end
end
