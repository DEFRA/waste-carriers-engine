# frozen_string_literal: true

DefraRubyEmail.configure do |configuration|
  configuration.notify_api_key = ENV.fetch("NOTIFY_API_KEY", nil)
end
