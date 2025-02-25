# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookPaymentService < GovpayWebhookBaseService

    VALID_STATUS_TRANSITIONS = {
      Payment::STATUS_CREATED => %w[started submitted success failed cancelled error],
      Payment::STATUS_STARTED => %w[submitted success failed cancelled error],
      Payment::STATUS_SUBMITTED => %w[success failed cancelled error],
      Payment::STATUS_SUCCESS => %w[],
      Payment::STATUS_FAILED => %w[],
      Payment::STATUS_CANCELLED => %w[],
      "error" => %w[]
    }.freeze

    private

    def update_payment_or_refund_status
      wcr_payment.update(govpay_payment_status: webhook_payment_or_refund_status)
      wcr_payment.finance_details.update_balance
      wcr_payment.finance_details.registration.save!

      Rails.logger.info "Updated status from #{previous_status} to #{webhook_payment_or_refund_status} " \
                        "for #{log_webhook_context}"
    end

    def log_webhook_context
      "for payment #{webhook_payment_or_refund_id}, registration #{@registration.regIdentifier}"
    end

    def payment_or_refund_str
      "payment"
    end

    def validate_webhook_body
      raise ArgumentError, "Invalid webhook type #{webhook_resource_type}" unless webhook_resource_type == "payment"

      return unless webhook_payment_or_refund_status.blank?

      raise ArgumentError, "Webhook body missing payment status: #{webhook_body}"
    end

    def webhook_resource_type
      @webhook_resource_type ||= webhook_body["resource_type"]&.downcase
    end

    def webhook_payment_or_refund_id
      @webhook_payment_or_refund_id ||= webhook_body.dig("resource", "payment_id")
    end

    def webhook_payment_or_refund_status
      @webhook_payment_or_refund_status ||= webhook_body.dig("resource", "state", "status")
    end
  end
end
