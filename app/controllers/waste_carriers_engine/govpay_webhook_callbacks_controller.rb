# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookCallbacksController < ::WasteCarriersEngine::ApplicationController
    protect_from_forgery with: :null_session

    def process_webhook
      pay_signature = request.headers["Pay-Signature"]
      # need to rewind in case already read
      request.body.rewind
      body = request.body.read

      raise ArgumentError, "Govpay payment webhook request missing Pay-Signature header" unless pay_signature.present?

      valid_signature = validate_signature(body, pay_signature)

      raise ArgumentError, "Invalid webhook signature" unless valid_signature

      GovpayWebhookJob.perform_later(JSON.parse(body))
    rescue StandardError, Mongoid::Errors::DocumentNotFound => e
      Rails.logger.error "Govpay payment webhook body validation failed: #{e}"
      Airbrake.notify(e, body: body, signature: pay_signature)
    ensure
      # always return 200 to Govpay even if validation fails
      render nothing: true, layout: false, status: 200
    end

    private

    def validate_signature(body, pay_signature)
      front_office_valid = DefraRubyGovpay::CallbackValidator.call(
        body,
        ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET"),
        pay_signature
      )

      unless front_office_valid
        back_office_valid = DefraRubyGovpay::CallbackValidator.call(
          body,
          ENV.fetch("WCRS_GOVPAY_BACK_OFFICE_CALLBACK_WEBHOOK_SIGNING_SECRET"),
          pay_signature
        )
      end

      front_office_valid || back_office_valid
    end
  end
end
