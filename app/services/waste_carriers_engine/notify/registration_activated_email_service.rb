# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RegistrationActivatedEmailService < BaseSendEmailService
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
            link_to_file: Notifications.prepare_upload(pdf)
          }
        }
      end

      def template_id
        if @registration.upper_tier?
          "fe1e4746-c940-4ace-b111-8be64ee53b35"
        else
          "889fa2f2-f70c-4b5a-bbc8-d94a8abd3990"
        end
      end

      def registration_type
        return unless @registration.upper_tier?

        I18n.t(
          "waste_carriers_engine.registration_type.upper.#{@registration.registration_type}"
        )
      end

      def registered_address
        certificate_presenter.registered_address_fields.join(", ")
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s
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
