# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistrationMailer < BaseMailer
    def registration_pending_worldpay_payment(registration)
      @registration = registration

      subject = I18n.t(".waste_carriers_engine.new_registration_mailer.registration_pending_worldpay_payment.subject",
                       reg_identifier: @registration.reg_identifier)

      mail(to: @registration.contact_email,
           from: from_email,
           subject: subject)
    end
  end
end
