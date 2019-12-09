# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistrationMailer < ActionMailer::Base
    helper "waste_carriers_engine/application"
    helper "waste_carriers_engine/mailer"

    def registration_activated(registration)
      @registration = registration

      mail(to: @registration.contact_email,
           from: "#{Rails.configuration.email_service_name} <#{Rails.configuration.email_service_email}>",
           subject: I18n.t(".waste_carriers_engine.new_registration_mailer.registration_activated.subject"))
    end
  end
end
