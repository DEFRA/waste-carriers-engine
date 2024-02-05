# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class CertificateRenewalEmailService < BaseSendEmailService
      include WasteCarriersEngine::ApplicationHelper
      include WasteCarriersEngine::CanRecordCommunication

      TEMPLATE_ID = "2eae1dbd-08c1-4602-a4d2-e4481a1acc97"
      COMMS_LABEL = "Resend certificate link"

      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: template_id,
          personalisation: {
            registration_type: registration_type,
            reg_identifier: @registration.reg_identifier,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            registered_address: registered_address,
            date_registered: date_registered,
            phone_number: @registration.phone_number,
            link_to_file: WasteCarriersEngine::ViewCertificateLinkService.run(registration: @registration,
                                                                              renew_token: true)
          }
        }
      end

      def registration_type
        return unless @registration.upper_tier?

        I18n.t(
          "waste_carriers_engine.registration_type.upper.#{@registration.registration_type}"
        )
      end

      def link_to_file
        return unless @registration.view_certificate_token

        WasteCarriersEngine::Engine.routes.url_helpers.certificate_url(
          host: Rails.configuration.wcrs_frontend_url,
          reg_identifier: @registration.reg_identifier,
          token: @registration.view_certificate_token
        )
      end

      def registered_address
        displayable_address(@registration.contact_address).join(", ")
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s(:standard)
      end
    end
  end
end
