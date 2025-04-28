# frozen_string_literal: true

module WasteCarriersEngine
  class ValidateGovpayWebhookBodyService < BaseService
    class ValidationFailure < StandardError; end

    def run(body:, signature:)
      raise ValidationFailure, "Missing expected signature" if signature.blank?

      body_signature = DefraRubyGovpay::GovpayWebhookSignatureService.run(body:)
      return true if body_signature == signature

      raise ValidationFailure, "digest/signature header mismatch"
    end
  end
end
