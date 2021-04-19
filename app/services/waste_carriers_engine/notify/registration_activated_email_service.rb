# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RegistrationActivatedEmailService < BaseSendEmailService
      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "889fa2f2-f70c-4b5a-bbc8-d94a8abd3990",
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            registration_type: @registration.registration_type,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            phone_number: @registration.phone_number,
            registered_address: registered_address,
            date_registered: @registration.metaData.date_registered,
            link_to_file: Notifications.prepare_upload(pdf)
          }
        }
      end

      def registered_address
        certificate_presenter.registered_address_fields.join(", ")
      end

      def certificate_presenter
        @_certificate_presenter ||= CertificatePresenter.new(@registration)
      end

      def pdf
        StringIO.new(pdf_content)
      end

      def pdf_content
        ActionController::Base.new.render_to_string(
          pdf: "certificate",
          template: "waste_carriers_engine/pdfs/certificate",
          encoding: "UTF-8",
          layout: false,
          locals: { presenter: certificate_presenter }
        )
      end
    end
  end
end
