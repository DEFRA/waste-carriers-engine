# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistrationMailer < BaseMailer
    def registration_activated(registration)
      @registration = registration

      certificate = generate_pdf_certificate
      attachments["WasteCarrierRegistrationCertificate-#{registration.reg_identifier}.pdf"] = certificate if certificate

      subject = I18n.t(".waste_carriers_engine.new_registration_mailer.registration_activated.subject")
      template = registration_activated_template

      mail(to: @registration.contact_email,
           from: from_email,
           subject: subject) do |format|
        format.html { render template }
      end
    end

    private

    def registration_activated_template
      if @registration.upper_tier?
        "registration_activated"
      else
        "lower_tier_registration_activated"
      end
    end
  end
end
