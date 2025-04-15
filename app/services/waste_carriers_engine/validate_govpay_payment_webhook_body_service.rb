# frozen_string_literal: true

module WasteCarriersEngine
  class ValidateGovpayPaymentWebhookBodyService < BaseService
    class ValidationFailure < StandardError; end

    def run(body:, signature:)
      raise ValidationFailure, "Missing expected signature" if signature.blank?

      valid_signature = DefraRubyGovpay::CallbackValidator.call(
        body,
        ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET"),
        signature
      ) || DefraRubyGovpay::CallbackValidator.call(
        body,
        ENV.fetch("WCRS_GOVPAY_BACK_OFFICE_CALLBACK_WEBHOOK_SIGNING_SECRET"),
        signature
      )

      raise ValidationFailure, "digest/signature header mismatch" unless valid_signature

      true
    end
  end
end
