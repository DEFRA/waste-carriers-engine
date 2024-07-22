# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookCallbacksController < ::WasteCarriersEngine::ApplicationController
    protect_from_forgery with: :null_session

    def process_webhook
      pay_signature = request.headers["Pay-Signature"]
      body = request.body.read

      raise ArgumentError, "Govpay payment webhook request missing Pay-Signature header" unless pay_signature.present?

      ValidateGovpayPaymentWebhookBodyService.run(body: body, signature: pay_signature)

      GovpayWebhookJob.perform_later(JSON.parse(body))
    rescue StandardError, Mongoid::Errors::DocumentNotFound => e
      Rails.logger.error "Govpay payment webhook body validation failed: #{e}"
      Airbrake.notify(e, body: body, signature: pay_signature)
    ensure
      # always return 200 to Govpay even if validation fails
      render nothing: true, layout: false, status: 200
    end
  end
end
