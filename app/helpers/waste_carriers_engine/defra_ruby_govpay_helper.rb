# frozen_string_literal: true

module WasteCarriersEngine

  # This module is used by the applications to set the govpay callback and next
  # URLs for a Gov.UK Pay payment, taking account whether the mocks are enabled.
  module DefraRubyGovpayHelper

    def self.govpay_callback_url(transient_registration, order)
      host = Rails.configuration.host
      path = WasteCarriersEngine::Engine.routes.url_helpers.payment_callback_govpay_forms_path(
        token: transient_registration.token, uuid: order.payment_uuid
      )

      [host, path].join
    end

    def self.govpay_next_url(url)
      return url unless ENV["WCRS_MOCK_ENABLED"].to_s.downcase == "true"

      return url unless Rails.env.production?

      if WasteCarriersEngine.configuration.host_is_back_office?
        mocks_url_var = "WCRS_MOCK_BO_GOVPAY_URL"
        external_url_var = "WCRS_PUBLIC_DOMAIN"
      else
        mocks_url_var = "WCRS_MOCK_FO_GOVPAY_URL"
        external_url_var = "WCRS_BACK_OFFICE_DOMAIN"
      end

      mocks_url = ENV.fetch(mocks_url_var)
      mocks_url_root = url_root(mocks_url)
      external_url = ENV.fetch(external_url_var)

      url.gsub(mocks_url_root, external_url)
    end

    def self.url_root(url)
      uri = URI.parse(url)
      url_root = "#{uri.scheme}://#{uri.host}"
      url_root += ":#{uri.port}" if uri.port.present?

      url_root
    end
  end
end
