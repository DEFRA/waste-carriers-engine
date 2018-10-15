module WasteCarriersEngine
  class RenewalMailer < ActionMailer::Base
    helper "waste_carriers_engine/application"
    helper "waste_carriers_engine/mailer"

    def send_renewal_complete_email(registration)
      @registration = registration

      certificate = generate_pdf_certificate
      attachments["WasteCarrierRegistrationCertificate-#{registration.reg_identifier}.pdf"] = certificate if certificate

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

    # We wrap the generation of the pdf in a rescue block, because though it's
    # not ideal that the user doesn't get their certificate attached if an error
    # occurs, we also don't want to block their renewal from completing because
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
      Airbrake.notify(e, { registration_no: @registration.reg_identifier }) if defined?(Airbrake)
      nil
    end
  end
end
