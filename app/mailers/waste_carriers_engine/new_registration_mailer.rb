# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistrationMailer < BaseMailer
    def registration_activated(registration)
      @registration = registration

      certificate = generate_pdf_certificate
      attachments["WasteCarrierRegistrationCertificate-#{registration.reg_identifier}.pdf"] = certificate if certificate

      mail(to: @registration.contact_email,
           from: from_email,
           subject: I18n.t(".waste_carriers_engine.new_registration_mailer.registration_activated.subject"))
    end

    def registration_pending_payment(registration)
      @registration = registration

      subject = I18n.t(".waste_carriers_engine.new_registration_mailer.registration_pending_payment.subject",
                       reg_identifier: @registration.reg_identifier)

      mail(to: @registration.contact_email,
           from: from_email,
           subject: subject)
    end

    def registration_pending_conviction_check(registration)
      @registration = registration

      subject = I18n.t(".waste_carriers_engine.new_registration_mailer.registration_pending_conviction_check.subject",
                       reg_identifier: @registration.reg_identifier)

      mail(to: @registration.contact_email,
           from: from_email,
           subject: subject)
    end
  end
end
