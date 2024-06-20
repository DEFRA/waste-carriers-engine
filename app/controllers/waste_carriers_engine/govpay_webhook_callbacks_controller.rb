# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookCallbacksController < ::WasteCarriersEngine::ApplicationController
    protect_from_forgery with: :null_session

    def process_webhook
      Rails.logger.warn "Processing govpay webhook, headers: #{request.headers}\n#{request.body.read}"

      pay_signature = request.headers["Pay-Signature"]

      raise ArgumentError, "Govpay payment webhook request missing Pay-Signature header" unless pay_signature.present?

      ValidateGovpayPaymentWebhookBodyService.run(body: request.body, signature: pay_signature)
    rescue StandardError => e
      Rails.logger.error "Govpay payment webhook body validation failed: #{e}"
      Airbrake.notify(e, body: request.body, signature: pay_signature)
    ensure
      # always return 2xx to Govpay even if validation fails
      render nothing: true, layout: false, status: 200
    end
  end
end
