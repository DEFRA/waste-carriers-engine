# frozen_string_literal: true

DefraRubyEmail.configure do |configuration|
  configuration.notify_api_key = ENV["NOTIFY_API_KEY"]
end
