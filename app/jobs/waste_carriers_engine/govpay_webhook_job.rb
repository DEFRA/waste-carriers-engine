# frozen_string_literal: true

require "waste_carriers_engine/detailed_logger"

module WasteCarriersEngine
  class GovpayWebhookJob < ApplicationJob
    def perform(webhook_body)
      if webhook_body["resource_type"]&.downcase == "payment"
        GovpayPaymentWebhookHandler.run(webhook_body)
      elsif webhook_body["refund_id"].present?
        GovpayRefundWebhookHandler.run(webhook_body)
      else
        raise ArgumentError, "Unrecognised Govpay webhook type"
      end
    rescue StandardError => e
      handle_error(e, webhook_body)
    end

    private

    def sanitize_webhook_body(body)
      DefraRubyGovpay::WebhookSanitizerService.call(body)
    end

    def handle_error(error, webhook_body)
      service_type = webhook_body.dig("resource", "moto") ? "back_office" : "front_office"
      Rails.logger.error "Error running GovpayWebhookJob (#{service_type}): #{error}"
      notification_params = {
        refund_id: webhook_body&.dig("resource", "refund_id") || webhook_body&.dig("refund_id"),
        payment_id: webhook_body&.dig("resource", "payment_id") || webhook_body&.dig("payment_id"),
        service_type: service_type
      }

      if FeatureToggle.active?(:detailed_logging)
        notification_params[:webhook_body] = sanitize_webhook_body(webhook_body)
        DetailedLogger.error "Webhook job error #{error}: #{notification_params}"
      end

      Airbrake.notify(error, notification_params)
    end
  end
end
