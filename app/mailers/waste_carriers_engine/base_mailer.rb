# frozen_string_literal: true

module WasteCarriersEngine
  class BaseMailer < ActionMailer::Base
    helper "waste_carriers_engine/application"
    helper "waste_carriers_engine/mailer"

    private

    def to_email
      @registration.contact_email
    end

    def from_email
      "#{Rails.configuration.email_service_name} <#{Rails.configuration.email_service_email}>"
    end

    # We wrap the generation of the pdf in a rescue block, because though it's
    # not ideal that the user doesn't get their certificate attached if an error
    # occurs, we also don't want to block other processes from completing because
    # of it
    def generate_pdf_certificate
      @presenter = CertificatePresenter.new(@registration, view_context)
      pdf_generator = GeneratePdfService.new(
        render_to_string(
          pdf: "certificate",
          template: "waste_carriers_engine/pdfs/certificate"
        )
      )
      pdf_generator.pdf
    rescue StandardError => e
      Airbrake.notify(e, registration_no: @registration.reg_identifier) if defined?(Airbrake)
      nil
    end
  end
end
