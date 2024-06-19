# frozen_string_literal: true

module WasteCarriersEngine
  class ValidateGovpayPaymentWebhookBodyService < BaseService
    class ValidationFailure < StandardError; end

    def run(body:, signature:)
      return true if hmac_digest(body.to_s) == signature

      raise ValidationFailure, "digest/signature header mismatch" unless hmac_digest(body.to_s) == signature
    rescue StandardError => e
      Rails.logger.error "Govpay payment webhook body validation failed: #{e}"
      Airbrake.notify(e, body:, signature:)
      raise e
    end

    private

    def webhook_signing_secret
      @webhook_signing_secret = ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET")
    end

    def hmac_digest(body)
      digest = OpenSSL::Digest.new("sha256")
      OpenSSL::HMAC.digest(digest, webhook_signing_secret, body)
    end
  end
end
