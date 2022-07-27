# frozen_string_literal: true

module WasteCarriersEngine
  class BaseRegistrationPermissionChecksService < BaseService
    delegate :registration, to: :transient_registration

    attr_reader :transient_registration, :user, :permission_check_result

    def run(transient_registration:, user:)
      @transient_registration = transient_registration
      @user = user
      @permission_check_result = PermissionChecksResult.new

      permission_check_result.pass! if all_checks_pass?

      permission_check_result
    end

    private

    def can?(action, object)
      unless user.present?
        e = StandardError.new(
          "Permissions check requested for nil user, "\
          "action: #{action}, "\
          "reg_identifier #{@transient_registration.reg_identifier}, "\
          "from_magic_link: #{@transient_registration.from_magic_link ? 'true' : 'false'}, "\
          "workflow_state: #{@transient_registration.workflow_state}, "\
          "workflow_history: #{@transient_registration.workflow_history}, "\
          "expires_on: #{@transient_registration.expires_on}, "\
          "renew_token: #{@transient_registration.registration.renew_token}, "\
          "metaData.route: #{@transient_registration.metaData.route}, "\
          "transient_registration created_at: #{@transient_registration.created_at}, "\
        )

        Airbrake.notify(e, reg_identifier: @transient_registration.reg_identifier) if defined?(Airbrake)
        Rails.logger.warn e

        # TODO: Continue so the original error is visible in the logs along with the debug info.
        # TODO: Revisit this and remove the additional debugging pending further investigation.
      end

      ability = Ability.new(user)

      ability.can?(action, object)
    end

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
