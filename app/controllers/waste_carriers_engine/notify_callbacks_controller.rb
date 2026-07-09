# frozen_string_literal: true

module WasteCarriersEngine
  class NotifyCallbacksController < ::WasteCarriersEngine::ApplicationController
    class TokenNotConfiguredError < StandardError; end
    class MissingAuthorizationError < StandardError; end
    class InvalidTokenError < StandardError; end

    protect_from_forgery with: :null_session

    def process_callback
      validate_bearer_token!

      # need to rewind in case already read
      request.body.rewind
      body = request.body.read
      payload = JSON.parse(body)

      NotifyCallbackJob.perform_later(payload)
    rescue StandardError => e
      Rails.logger.error "Notify callback error: #{e}"
      Airbrake.notify(e)
    ensure
      # always return 200 to Notify even if validation fails
      head :ok
    end

    private

    def validate_bearer_token!
      expected_token = ENV.fetch("NOTIFY_CALLBACK_BEARER_TOKEN", nil)
      raise TokenNotConfiguredError, "Notify callback bearer token not configured" if expected_token.blank?

      auth_header = request.headers["Authorization"]
      raise MissingAuthorizationError, "Missing Authorization header" if auth_header.blank?

      token = auth_header.sub(/\ABearer\s+/, "")
      return if ActiveSupport::SecurityUtils.secure_compare(token, expected_token)

      raise InvalidTokenError, "Invalid bearer token"
    end
  end
end
