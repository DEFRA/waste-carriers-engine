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
        Rails.logger.warn "****** DefraRubyGovpayHelper 1: host \"#{host}\", path: \"#{path}\""
        host = url_root(ENV.fetch("WCRS_MOCK_BO_GOVPAY_URL")) || host
        # path.gsub!(/^\/fo/, "")
        Rails.logger.warn "****** DefraRubyGovpayHelper 2: host \"#{host}\", path: \"#{path}\""
      end
      Rails.logger.warn ">>> DefraRubyGovpayHelper: FINAL callback_url \"#{[host, path].join}\""

      [host, path].join
    end

    def self.govpay_next_url(url)
      return url unless ENV["WCRS_MOCK_ENABLED"].to_s.downcase == "true"

      return url unless Rails.env.production?

      external_url_var = WasteCarriersEngine.configuration.host_is_back_office? ? "WCRS_PUBLIC_DOMAIN" : "WCRS_BACK_OFFICE_DOMAIN"
      mocks_url = ENV.fetch(external_url_var)
      DetailedLogger.warn "next_url for #{url}, using env var \"#{external_url_var}\" => \"#{ENV.fetch(external_url_var)}\""
      DetailedLogger.warn "mocks_url: \"#{mocks_url}\", mocks_url root: \"#{url_root(mocks_url)}\""
      DetailedLogger.warn "next_url: \"#{url.gsub!(url_root(mocks_url), ENV.fetch(external_url_var))}\""
      url.gsub!(url_root(mocks_url), ENV.fetch(external_url_var))
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
