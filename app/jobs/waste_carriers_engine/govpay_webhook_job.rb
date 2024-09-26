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
      Rails.logger.error "Error running GovpayWebhookJob: #{e}"
      Airbrake.notify(
        e,
        refund_id: webhook_body["refund_id"],
        payment_id: webhook_body["payment_id"]
      )
    end
  end
end
