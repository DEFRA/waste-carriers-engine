module WasteCarriersEngine
  class RenewalMailer < ActionMailer::Base
    add_template_helper(MailerHelper)

    def send_renewal_complete_email(registration)
      @registration = registration
      @address_lines = displayable_address(@registration.registered_address)

      mail(to: @registration.contact_email,
           from: "#{Rails.configuration.email_service_name} <#{Rails.configuration.email_service_email}>",
           subject: I18n.t(".waste_carriers_engine.renewal_mailer.send_renewal_complete_email.subject",
                           reg_identifier: @registration.reg_identifier) )
    end

    private

    def displayable_address(address)
      return [] unless address.present?
      # Get all the possible address lines, then remove the blank ones
      [address.address_line_1,
       address.address_line_2,
       address.address_line_3,
       address.address_line_4,
       address.town_city,
       address.postcode,
       address.country].reject
    end
  end
end
