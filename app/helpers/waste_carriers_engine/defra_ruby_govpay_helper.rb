# frozen_string_literal: true

module WasteCarriersEngine

  # This module is used by the applications to set the govpay callback URL for a
  # Gov.UK Pay payment, taking account whether the mocks are enabled.
  module DefraRubyGovpayHelper

    def self.govpay_callback_url(transient_registration, order)
      host = Rails.configuration.host
      path = WasteCarriersEngine::Engine.routes.url_helpers.payment_callback_govpay_forms_path(
        token: transient_registration.token, uuid: order.payment_uuid
      )
      Rails.logger.warn ">>> DefraRubyGovpayHelper: initial callback_url \"#{[host, path].join}\""
      # If using the mocks, adapt the callback_url to align with the root of the mocks path
      # so that the back-office can reach the front-office.
      if ENV["WCRS_MOCK_ENABLED"].to_s.downcase == "true"
        host = url_root(ENV.fetch("WCRS_MOCK_FO_GOVPAY_URL")) || host
      end
      Rails.logger.warn ">>> DefraRubyGovpayHelper: FINAL callback_url \"#{[host, path].join}\""

      [host, path].join
    end

    def self.url_root(url)
      uri = URI.parse(url)
      url_root = "#{uri.scheme}://#{uri.host}"
      url_root += ":#{uri.port}" if uri.port.present?

      url_root
    end
  end
end
