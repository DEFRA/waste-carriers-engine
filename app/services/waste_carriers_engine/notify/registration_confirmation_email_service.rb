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
            link_to_file: link_to_certificate,
            certificate_creation_date: Date.today.strftime("%e %B %Y")
          }
        }
      end

      def template_id
        @registration.upper_tier? ? "4526496c-1ae0-4dc6-a564-c7007b76c164" : "8d1fb650-93ef-4260-aa08-0b703bbe5609"
      end

      def registered_address
        certificate_presenter.registered_address_fields.join("\r\n")
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s
      end

      def certificate_presenter
        @_certificate_presenter ||= CertificatePresenter.new(@registration)
      end
    end
  end
end
