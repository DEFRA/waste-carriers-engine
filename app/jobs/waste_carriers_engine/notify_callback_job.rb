# frozen_string_literal: true

module WasteCarriersEngine
  class NotifyCallbackJob < ApplicationJob
    self.log_arguments = false

    def perform(callback_payload)
      result = NotifyCallbackHandlerService.run(callback_payload)

      Rails.logger.info "Processed Notify callback for notification_id: #{result[:notification_id]}, " \
                        "status: #{result[:status]}"
    rescue StandardError => e
      notification_id = callback_payload["id"] || callback_payload["notification_id"]
      Rails.logger.error "Error running NotifyCallbackJob for notification_id #{notification_id}: #{e}"
      Airbrake.notify(e, notification_id: notification_id)
    end
  end
end
