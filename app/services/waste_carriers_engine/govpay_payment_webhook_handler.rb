# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayPaymentWebhookHandler < BaseService
    attr_accessor :payment_id, :payment, :registration, :webhook_body, :previous_status

    def run(webhook_body)
      @webhook_body = webhook_body
      @payment_id = webhook_body.dig("resource", "payment_id")
      @payment = GovpayFindPaymentService.run(payment_id: payment_id)

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
      Airbrake.notify "Error processing webhook for payment #{payment_id}", e
      raise
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

      remove_expired_payment

      complete_registration_or_renewal_if_ready
    end

    def update_payment_status
      payment.update(govpay_payment_status: webhook_payment_status)
      payment.finance_details.update_balance
      (payment.finance_details.registration || payment.finance_details.transient_registration).save!
    end

    def remove_expired_payment
      return unless webhook_payment_status == "expired"

      # If the payment is on a transient_registration, prevent retries from reusing the old next_url:
      transient_registration = payment.finance_details.transient_registration
      transient_registration&.update(temp_govpay_next_url: nil)
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
