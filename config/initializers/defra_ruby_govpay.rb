# frozen_string_literal: true

require "defra_ruby_govpay"

DefraRubyGovpay.configure do |config|
  config.govpay_url = Rails.configuration.govpay_url
  config.govpay_front_office_api_token = Rails.configuration.govpay_front_office_api_token
  config.govpay_back_office_api_token = Rails.configuration.govpay_back_office_api_token
  config.logger = Rails.logger
  config.front_office_webhook_signing_secret = ENV.fetch("WCRS_GOVPAY_CALLBACK_WEBHOOK_SIGNING_SECRET", nil)
  config.back_office_webhook_signing_secret = ENV.fetch("WCRS_GOVPAY_BACK_OFFICE_CALLBACK_WEBHOOK_SIGNING_SECRET", nil)
end
