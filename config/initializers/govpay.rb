# frozen_string_literal: true

require "defra_ruby_govpay"

DefraRubyGovpay.configure do |config|
  config.govpay_url = Rails.configuration.govpay_url
  config.govpay_front_office_api_token = Rails.configuration.govpay_front_office_api_token
  config.govpay_back_office_api_token = Rails.configuration.govpay_back_office_api_token
  config.host_is_back_office = WasteCarriersEngine.configuration.host_is_back_office?
end

DefraRubyGovpayAPI = DefraRubyGovpay::API.new
