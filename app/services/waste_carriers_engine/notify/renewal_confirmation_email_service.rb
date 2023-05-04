# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RenewalConfirmationEmailService < BaseSendEmailService
      include CanAttachCertificate

      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "ce2d9d55-6e16-45fe-83e2-4513a31ea864",
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            registration_type: registration_type,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            phone_number: @registration.phone_number,
            registered_address: registered_address,
            date_activated: date_activated,
            link_to_file: link_to_certificate,
            certificate_creation_date: Date.today.strftime("%e %B %Y")
          }
        }
      end

      def registered_address
        certificate_presenter.registered_address_fields.join("\r\n")
      end

      def date_activated
        @registration.metaData.date_activated.in_time_zone("London").to_date.to_s
      end

      def certificate_presenter
        @_certificate_presenter ||= CertificatePresenter.new(@registration)
      end
    end
  end
end
