module WasteCarriersEngine
  class RenewalMailer < ActionMailer::Base
    helper "waste_carriers_engine/application"
    helper "waste_carriers_engine/mailer"

    def send_renewal_complete_email(registration)
      @registration = registration

      mail(to: @registration.contact_email,
           from: "#{Rails.configuration.email_service_name} <#{Rails.configuration.email_service_email}>",
           subject: I18n.t(".waste_carriers_engine.renewal_mailer.send_renewal_complete_email.subject",
                           reg_identifier: @registration.reg_identifier) )
    end

    def send_renewal_received_email(transient_registration)
      @transient_registration = transient_registration
      @total_to_pay = @transient_registration.finance_details.balance

      template = renewal_received_template
      subject = I18n.t(".waste_carriers_engine.renewal_mailer.#{template}.subject",
                       reg_identifier: @transient_registration.reg_identifier)

      mail(to: @transient_registration.contact_email,
           from: "#{Rails.configuration.email_service_name} <#{Rails.configuration.email_service_email}>",
           subject: subject ) do |format|
        format.html { render template }
      end
    end

    private

    def renewal_received_template
      if @transient_registration.pending_worldpay_payment?
        "send_renewal_received_processing_payment_email"
      elsif @transient_registration.pending_payment?
        "send_renewal_received_pending_payment_email"
      else
        "send_renewal_received_pending_conviction_check_email"
      end
    end
  end
end
