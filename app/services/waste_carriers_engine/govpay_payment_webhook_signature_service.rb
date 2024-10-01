# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayPaymentWebhookSignatureService < BaseService
    class DigestFailure < StandardError; end

    def run(body:)
      generate_signatures(body.to_s)
    rescue StandardError => e
      Rails.logger.error "Govpay payment webhook signature generation failed: #{e}"
      Airbrake.notify(e, body:)
      raise DigestFailure, e
    end

    private

    def generate_signatures(body)
      {
        front_office: hmac_digest(body, front_office_secret),
        back_office: hmac_digest(body, back_office_secret)
      }
    end

    def front_office_secret
      ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET")
    end

    def back_office_secret
      ENV.fetch("WCRS_GOVPAY_BACK_OFFICE_CALLBACK_WEBHOOK_SIGNING_SECRET")
    end

    def hmac_digest(body, secret)
      digest = OpenSSL::Digest.new("sha256")
      OpenSSL::HMAC.hexdigest(digest, secret, body)
    end
  end
end
