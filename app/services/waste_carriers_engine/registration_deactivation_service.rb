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

      send_confirmation_email unless WasteCarriersEngine.configuration.host_is_back_office?
    end

    private

    def set_metadata
      if WasteCarriersEngine.configuration.host_is_back_office?
        deactivation_channel = "BACK OFFICE"
      else
        @reason = I18n.t(".front_office_deactivation_reason", email: registration.contact_email)
        @status = "INACTIVE"
        @email = registration.contact_email
        deactivation_channel = "DIGITAL"
      end

      registration.metaData.status = @status
      registration.metaData.revoked_reason = @reason
      registration.metaData.deactivated_by = @email
      registration.metaData.deactivation_route = deactivation_channel
      registration.metaData.dateDeactivated = Time.zone.now

      registration.save!
    end

    def send_confirmation_email
      Notify::DeregistrationConfirmationEmailService.run(registration: registration)
    end
  end
end
