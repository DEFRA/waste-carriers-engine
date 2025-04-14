# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayRefundHandler
    def self.process(webhook_body)
      DefraRubyGovpay::GovpayWebhookRefundService.run(webhook_body) do |args|
        refund_id = args[:id]
        payment_id = webhook_body["payment_id"]
        status = args[:status]

        begin
          refund = GovpayFindPaymentService.run(payment_id: refund_id)
          return if refund.blank?

          registration = GovpayFindRegistrationService.run(payment: refund)
          return if registration.blank?

          # Store previous status for logging
          previous_status = refund.govpay_payment_status

          # Use the existing service to update the refund status
          GovpayUpdateRefundStatusService.new.run(
            registration: registration,
            refund_id: refund_id,
            new_status: status
          )

          Rails.logger.info "Updated status from #{previous_status} to #{status} for refund #{refund_id}, payment #{payment_id}, registration #{registration.regIdentifier}"
        rescue StandardError => e
          Rails.logger.error "Error processing webhook for refund #{refund_id}, payment #{payment_id}: #{e}"
          Airbrake.notify "Error processing webhook for refund #{refund_id}, payment #{payment_id}", e
        end
      end
    end
  end
end
