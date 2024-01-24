# frozen_string_literal: true

module WasteCarriersEngine
  class CertificateRenewalService < BaseService
    def run(registration:)
      @registration = registration
      @registration.generate_view_certificate_token!
      send_email
      true
    rescue StandardError => e
      Airbrake.notify(e, registration: @registration.reg_identifier) if defined?(Airbrake)
      Rails.logger.error(e)
      false
    end

    private

    def send_email
      Notify::CertificateRenewalEmailService.run(registration: @registration)
    end
  end
end
