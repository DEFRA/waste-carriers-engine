# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RegistrationConfirmationEmailService < BaseSendEmailService
      LOWER_TIER_TEMPLATE_ID = "591d1a44-9c0a-43a5-a76f-235e67df27d8"
      LOWER_TIER_COMMS_LABEL = "Lower tier registration complete"

      UPPER_TIER_TEMPLATE_ID = "603840fe-de9e-4824-9715-d975b88ff438"
      UPPER_TIER_COMMS_LABEL = "Upper tier registration complete"

      private

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
            link_to_file: WasteCarriersEngine::ViewCertificateLinkService.run(registration: @registration),
            unsubscribe_link: WasteCarriersEngine::UnsubscribeLinkService.run(registration: @registration)
          }
        }
      end

      def template_id
        @registration.upper_tier? ? UPPER_TIER_TEMPLATE_ID : LOWER_TIER_TEMPLATE_ID
      end

      def comms_label
        @registration.upper_tier? ? UPPER_TIER_COMMS_LABEL : LOWER_TIER_COMMS_LABEL
      end

      def registered_address
        certificate_presenter.registered_address_fields.join("\r\n")
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s(:standard)
      end

      def certificate_presenter
        @_certificate_presenter ||= CertificateGeneratorService.run(registration: @registration,
                                                                    requester: @requester)
      end
    end
  end
end
