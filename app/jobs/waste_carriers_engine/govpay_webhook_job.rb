# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookJob < ApplicationJob
    def perform(webhook_body)
      WasteCarriersEngine::GovpayWebhookPaymentService.run(webhook_body)
    rescue StandardError => e
      Rails.logger.error "Error running GovpayWebhookJob: #{e}"
      Airbrake.notify(e, webhook_body:)
    end
  end
end
