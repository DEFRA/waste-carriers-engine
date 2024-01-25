# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationConfirmationService < BaseService
    def run(registration:)
      registration.generate_view_certificate_token!
      send_email_or_letter(registration)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
      Rails.logger.error e
    end

    private

    def send_email_or_letter(registration)
      if registration.assisted_digital?
        Notify::RegistrationConfirmationLetterService.run(registration: registration)
      else
        Notify::RegistrationConfirmationEmailService.run(registration: registration)
      end
    end
  end
end
