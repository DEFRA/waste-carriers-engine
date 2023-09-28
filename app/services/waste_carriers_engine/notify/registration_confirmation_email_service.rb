# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RegistrationConfirmationEmailService < BaseSendEmailService
      private

      include CanAttachCertificate

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: template_id,
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            registration_type: registration_type,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            phone_number: @registration.phone_number,
            registered_address: registered_address,
            date_registered: date_registered,
            link_to_file: link_to_certificate
          }
        }
      end

      def template_id
        @registration.upper_tier? ? "fe1e4746-c940-4ace-b111-8be64ee53b35" : "889fa2f2-f70c-4b5a-bbc8-d94a8abd3990"
      end

      def registered_address
        certificate_presenter.registered_address_fields.join("\r\n")
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s
      end

      def certificate_presenter
        @_certificate_presenter ||= CertificateGeneratorService.run(registration: @registration,
                                                                    requester: @requester)
      end
    end
  end
end
