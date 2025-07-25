# frozen_string_literal: true

SENSITIVE_ROUTES = [
  %r{/govpay_payment_update$}
].freeze

LOG_FORMAT = "Processing by %s#%s as %s"

ActiveSupport.on_load(:action_controller) do
  ActionController::LogSubscriber.class_eval do

    alias_method :original_start_processing, :start_processing

    def start_processing(event)
      payload = event.payload

      if SENSITIVE_ROUTES.any? { |route_regex| payload[:path]&.match?(route_regex) }
        info format(LOG_FORMAT, payload[:controller], payload[:action], payload[:format])

      else
        original_start_processing(event)
      end
    end
  end
end
