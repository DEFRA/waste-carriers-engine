# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookJob < ApplicationJob
    def perform(webhook_body)
      if webhook_body["resource_type"] == "payment"
        WasteCarriersEngine::GovpayWebhookPaymentService.run(webhook_body)
      elsif webhook_body["refund_id"].present?
        WasteCarriersEngine::GovpayWebhookRefundService.run(webhook_body)
      else
        raise ArgumentError, "Unrecognised Govpay webhook type: #{webhhook_body}"
      end
    rescue StandardError => e
      Rails.logger.error "Error running GovpayWebhookJob: #{e}"
      Airbrake.notify(e, webhook_body:)
    end
  end
end
