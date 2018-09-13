module WasteCarriersEngine
  class RenewalMailer < ActionMailer::Base
    def send_renewal_complete_email(registration)
      @registration = registration

      mail(to: @registration.contact_email,
           from: "WCR test <test@example.com>",
           subject: 'Renewal completed' )
    end
  end
end
