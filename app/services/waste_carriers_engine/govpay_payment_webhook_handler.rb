# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayPaymentWebhookHandler
    def self.process(webhook_body)
      payment_id = webhook_body.dig("resource", "payment_id")
      payment = GovpayFindPaymentService.run(payment_id: payment_id)

      previous_status = payment.govpay_payment_status
      webhook_status = webhook_payment_status(webhook_body, previous_status)
      if webhook_status == previous_status
        Rails.logger.debug "No change to payment status #{previous_status} for payment with govpay id \"#{payment_id}\""
        return
      end

      update_payment_status(payment, webhook_status)

      registration = GovpayFindRegistrationService.run(payment: payment)
      process_registration(registration, payment, webhook_status)

      Rails.logger.info "Updated status from #{previous_status} to #{webhook_status} for payment #{payment_id}, " \
                        "registration \"#{registration&.regIdentifier}\""
    rescue StandardError => e
      Rails.logger.error "Error processing webhook for payment #{payment_id}: #{e}"
      Airbrake.notify "Error processing webhook for payment #{payment_id}", e
      raise
    end

    def self.webhook_payment_status(webhook_body, previous_status)
      DefraRubyGovpay::WebhookPaymentService.run(
        webhook_body,
        previous_status: previous_status
      )[:status]
    end

    def self.process_registration(registration, payment, webhook_status)
      if registration.blank?
        Rails.logger.warn "Registration not found for payment with govpay id #{payment.govpay_id}"
        return
      end

      complete_registration_or_renewal_if_ready(registration, webhook_status)
    end

    def self.update_payment_status(payment, status)
      payment.update(govpay_payment_status: status)
      payment.finance_details.update_balance
      (payment.finance_details.registration || payment.finance_details.transient_registration).save!
    end

    def self.complete_registration_or_renewal_if_ready(registration, status)
      return unless status == "success"

      case registration
      when WasteCarriersEngine::NewRegistration
        RegistrationCompletionService.new.run(registration)
      when WasteCarriersEngine::RenewingRegistration
        RenewalCompletionService.new(registration).complete_renewal
      else
        # No need to do anything else for a Registration, this is just for lint purposes
        Rails.logger.debug "GovpayPaymentWebhookHandler: No completion action for resource type #{registration.class}"
      end
    end
  end
end
