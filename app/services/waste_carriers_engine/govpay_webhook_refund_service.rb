# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookRefundService < GovpayWebhookBaseService

    VALID_STATUS_TRANSITIONS = {
      Payment::STATUS_SUBMITTED => %w[success],
      Payment::STATUS_SUCCESS => %w[],
      "error" => %w[]
    }.freeze

    private

    def update_payment_or_refund_status
      WasteCarriersEngine::GovpayUpdateRefundStatusService.run(registration:, refund_id: webhook_payment_or_refund_id,
                                                               new_status: webhook_payment_or_refund_status)
      Rails.logger.info "Updated status from #{previous_status} to #{webhook_payment_or_refund_status} " \
                        "for #{log_webhook_context}"
    rescue StandardError => e
      Rails.logger.error "Error processing webhook for #{log_webhook_context}: #{e}"
      Airbrake.notify "Error processing webhook for #{log_webhook_context}", e
    end

    def log_webhook_context
      "refund #{webhook_payment_or_refund_id}, payment #{webhook_payment_id}, " \
        "registration #{registration.regIdentifier}"
    end

    def payment_or_refund_str
      "refund"
    end

    def validate_webhook_body
      return if webhook_payment_or_refund_id.present? && webhook_payment_or_refund_status.present?

      raise ArgumentError, "Invalid refund webhook: #{webhook_body}"
    end

    def webhook_payment_or_refund_status
      @webhook_payment_or_refund_status ||= webhook_body["status"]
    end

    def webhook_payment_id
      @webhook_payment_id ||= webhook_body["payment_id"]
    end

    def webhook_payment_or_refund_id
      @webhook_payment_or_refund_id ||= webhook_body["refund_id"]
    end
  end
end
