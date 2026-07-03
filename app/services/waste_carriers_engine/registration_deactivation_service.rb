# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationDeactivationService < BaseService
    attr_reader :registration, :email, :reason, :status

    def run(registration:, email: nil, reason: nil, status: nil)
      if %w[REVOKED INACTIVE].include?(registration.metaData.status)
        warning = "Attempted to deactivate #{registration.metaData.status} registration: " \
                  "\"#{registration&.reg_identifier}\""
        Airbrake.notify(warning)
        Rails.logger.warn warning
        return
      end

      @registration = registration
      @email = email
      @reason = reason
      @status = status

      set_metadata
    end

    private

    def set_metadata
      registration.metaData.status = @status
      registration.metaData.revoked_reason = @reason
      registration.metaData.deactivated_by = @email
      registration.metaData.deactivation_route = "BACK OFFICE"
      registration.metaData.dateDeactivated = Time.zone.now

      registration.save!
    end
  end
end
