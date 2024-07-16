# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayPaymentWebhookSignatureService < BaseService
    class DigestFailure < StandardError; end

    def run(body:)
      hmac_digest(body.to_s)
    rescue StandardError => e
      Rails.logger.error "Govpay payment webhook signature generation failed: #{e}"
      Airbrake.notify(e, body:, signature:)
      raise DigestFailure, e
    end

    private

    def webhook_signing_secret
      @webhook_signing_secret = ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET")
    end

    def hmac_digest(body)
      digest = OpenSSL::Digest.new("sha256")
      OpenSSL::HMAC.hexdigest(digest, webhook_signing_secret, body)
    end
  end
end
