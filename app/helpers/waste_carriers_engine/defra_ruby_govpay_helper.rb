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
        host = ENV.fetch("WCRS_MOCK_BO_GOVPAY_URL") || host
      end
      Rails.logger.warn ">>> DefraRubyGovpayHelper: FINAL callback_url \"#{[host, path].join}\""

      [host, path].join
    end

    def self.govpay_next_url(url)
      return url unless ENV["WCRS_MOCK_ENABLED"].to_s.downcase == "true"

      return url unless Rails.env.production?

      env_abbreviation = WasteCarriersEngine.configuration.host_is_back_office? ? "BO" : "FO"
      mocks_url = ENV.fetch("WCRS_MOCK_#{env_abbreviation}_GOVPAY_URL")
      url.gsub!(url_root(mocks_url), ENV.fetch("WCRS_PUBLIC_DOMAIN"))
    end

    private

    def self.url_root(url)
      uri = URI.parse(url)
      url_root = "#{uri.scheme}://#{uri.host}"

      if uri.port.present?
        url_root += ":#{uri.port}"
        # url_root += host_is_back_office? ? "/bo" : "/fo"
      end

      Rails.logger.warn ">>> DefraRubyGovpayHelper.url_root for url \"#{url}\", port #{uri.port} => url_root for callback is \"#{url_root}\""

      url_root
    end
  end
end
