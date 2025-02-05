# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookJob < ApplicationJob
    def perform(webhook_body)
      if webhook_body["resource_type"]&.downcase == "payment"
        WasteCarriersEngine::GovpayWebhookPaymentService.run(webhook_body)
      elsif webhook_body["refund_id"].present?
        WasteCarriersEngine::GovpayWebhookRefundService.run(webhook_body)
      else
        raise ArgumentError, "Unrecognised Govpay webhook type"
      end
    rescue StandardError => e
      service_type = webhook_body.dig("resource", "moto") ? "back_office" : "front_office"
      Rails.logger.error "Error running GovpayWebhookJob (#{service_type}): #{e}"
      Airbrake.notify(
        e,
        refund_id: webhook_body["refund_id"],
        payment_id: webhook_body["payment_id"],
        service_type: service_type,
        webhook_body: sanitize_webhook_body(webhook_body)
      )
    end

    private

    def sanitize_webhook_body(body)
      return body unless body.is_a?(Hash)

      # Deep clone the hash to avoid modifying the original
      sanitized = body.deep_dup

      # Remove PII fields if they exist
      if sanitized["resource"].is_a?(Hash)
        # Remove email and card details
        sanitized["resource"].delete("email_address")
        sanitized["resource"].delete("card_details")
      end

      sanitized
    end
  end
end
