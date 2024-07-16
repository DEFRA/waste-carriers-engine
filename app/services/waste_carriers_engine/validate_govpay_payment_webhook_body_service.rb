# frozen_string_literal: true

module WasteCarriersEngine
  class ValidateGovpayPaymentWebhookBodyService < BaseService
    class ValidationFailure < StandardError; end

    def run(body:, signature:)
      raise ValidationFailure, "Missing expected signature" if signature.blank?

      body_signature = GovpayPaymentWebhookSignatureService.run(body:)
      return true if body_signature == signature

      raise ValidationFailure, "digest/signature header mismatch"
    rescue StandardError => e
      Rails.logger.error "Govpay payment webhook body validation failed: #{e}"
      Airbrake.notify(e, body:, signature:)
      raise e
    end
  end
end
