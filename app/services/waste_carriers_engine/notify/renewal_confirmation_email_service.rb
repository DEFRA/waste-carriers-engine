# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RenewalConfirmationEmailService < BaseSendEmailService
      TEMPLATE_ID = "6d54a9bc-9b62-4d93-a40a-d06d04ed58ca"
      COMMS_LABEL = "Upper tier renewal complete"

      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: TEMPLATE_ID,
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            registration_type: registration_type,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            phone_number: @registration.phone_number,
            registered_address: registered_address,
            date_activated: date_activated,
            link_to_file: WasteCarriersEngine::ViewCertificateLinkService.run(registration: @registration)
          }
        }
      end

      def registered_address
        certificate_presenter.registered_address_fields.join("\r\n")
      end

      def date_activated
        @registration.metaData.date_activated.in_time_zone("London").to_date.to_s(:standard)
      end

      def certificate_presenter
        @_certificate_presenter ||= CertificateGeneratorService.run(registration: @registration,
                                                                    requester: @requester)
      end
    end
  end
end
