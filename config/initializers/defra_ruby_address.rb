# frozen_string_literal: true

DefraRuby::Address.configure do |config|
  config.host = ENV.fetch("WCRS_OSPLACES_URL")
  config.key = ENV.fetch("WCRS_OSPLACES_KEY")
end
