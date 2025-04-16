# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayRefundWebhookHandler
    def self.process(webhook_body)
      result = DefraRubyGovpay::GovpayWebhookRefundService.run(webhook_body)
      refund_id = result[:id]
      payment_id = result[:payment_id]
      status = result[:status]

      begin
        refund = GovpayFindPaymentService.run(payment_id: refund_id)
        return if refund.blank?

        registration = GovpayFindRegistrationService.run(payment: refund)
        return if registration.blank?

        previous_status = refund.govpay_payment_status

        update_refund_status(refund_id, registration, status)

        Rails.logger.info "Updated status from #{previous_status} to #{status} for refund #{refund_id}, " \
          "payment #{payment_id}, registration #{registration.regIdentifier}"
      rescue StandardError => e
        Rails.logger.error "Error processing webhook for refund #{refund_id}, payment #{payment_id}: #{e}"
        Airbrake.notify "Error processing webhook for refund #{refund_id}, payment #{payment_id}", e
      end
    end

    def self.update_refund_status(refund_id, registration, status)
      GovpayUpdateRefundStatusService.new.run(
        registration: registration,
        refund_id: refund_id,
        new_status: status
      )
    end
  end
end
