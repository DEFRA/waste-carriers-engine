# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayPaymentWebhookHandler < BaseService
    attr_accessor :payment_id, :payment, :registration, :webhook_body, :previous_status

    def run(webhook_body)
      @webhook_body = webhook_body
      @payment = find_payment

      return log_unrecorded_payment if payment.blank?

      @previous_status = payment.govpay_payment_status

      if webhook_payment_status == previous_status
        Rails.logger.debug "No change to payment status #{previous_status} for payment with govpay id \"#{payment_id}\""
        return
      end

      update_payment_status

      @registration = GovpayFindRegistrationService.run(payment:)

      process_registration

      Rails.logger.info "Updated status from #{previous_status} to #{webhook_payment_status} for " \
                        "payment #{payment_id}, registration \"#{registration&.regIdentifier}\""
    rescue StandardError => e
      Rails.logger.error "Error processing webhook for payment #{payment_id}: #{e}"
      Airbrake.notify(e, message: "Error processing webhook for payment", payment_id: payment_id)
      raise
    end

    # A payment document is only persisted once a payment succeeds, so a
    # missing payment is only a concern if the webhook reports success.
    # Uses the raw status here because webhook_payment_status memoizes the
    # gem result, which must not happen before previous_status is known.
    def find_payment
      @payment_id = webhook_body.dig("resource", "payment_id")
      GovpayFindPaymentService.run(
        payment_id: payment_id,
        raise_on_missing: raw_webhook_status == Payment::STATUS_SUCCESS
      )
    end

    def raw_webhook_status
      webhook_body.dig("resource", "state", "status")
    end

    def log_unrecorded_payment
      Rails.logger.warn "Ignoring \"#{raw_webhook_status}\" webhook for unrecorded payment #{payment_id}"
    end

    def webhook_payment_status
      @webhook_payment_status ||= DefraRubyGovpay::WebhookPaymentService.run(
        webhook_body,
        previous_status: previous_status
      )[:status]
    end

    def process_registration
      if registration.blank?
        Rails.logger.warn "Registration not found for payment with govpay id #{payment.govpay_id}"
        return
      end

      complete_registration_or_renewal_if_ready
    end

    def update_payment_status
      payment.update(govpay_payment_status: webhook_payment_status)
      payment.finance_details.update_balance
      (payment.finance_details.registration || payment.finance_details.transient_registration).save!
    end

    def complete_registration_or_renewal_if_ready
      return unless webhook_payment_status == "success"

      case registration
      when WasteCarriersEngine::Registration
        RegistrationActivationService.run(registration:)
      when WasteCarriersEngine::NewRegistration
        RegistrationCompletionService.run(registration)
      when WasteCarriersEngine::RenewingRegistration
        RenewalCompletionService.new(registration).complete_renewal
      else
        # No need to do anything else for a Registration, this is just for lint purposes
        Rails.logger.debug "GovpayPaymentWebhookHandler: No completion action for resource type #{registration.class}"
      end
    end
  end
end
