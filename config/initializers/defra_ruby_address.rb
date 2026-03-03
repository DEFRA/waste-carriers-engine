# frozen_string_literal: true

DefraRuby::Address.configure do |config|
  config.host = Rails.configuration.os_places_service_url
  config.key = Rails.configuration.os_places_api_key
end
