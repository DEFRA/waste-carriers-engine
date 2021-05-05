# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalMailer < BaseMailer
    def send_renewal_received_email(transient_registration)
      @transient_registration = transient_registration
      @total_to_pay = @transient_registration.finance_details.balance

      template = renewal_received_template
      subject = I18n.t(".waste_carriers_engine.renewal_mailer.#{template}.subject",
                       reg_identifier: @transient_registration.reg_identifier)

      mail(to: @transient_registration.contact_email,
           from: from_email,
           subject: subject) do |format|
        format.html { render template }
      end
    end

    private

    def renewal_received_template
      # pending worldpay payments have migrated to: RenewalPendingWorldpayPaymentEmailService
      # pending checks have migrated to: RenewalPendingChecksEmailService
      "send_renewal_received_pending_payment_email"
    end
  end
end
