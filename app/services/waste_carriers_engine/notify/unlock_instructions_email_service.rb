# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class UnlockInstructionsEmailService < BaseSendEmailService
      private
      def unlock_url
        Rails.application.routes.url_helpers.unlock_url(
          @record,
          host: Rails.configuration.x.notify.host,
          unlock_token: @token
        )
      end

      def notify_options
        {
          email_address: @record.email,
          template_id: "a3295516-26a6-4c01-9e3a-d5000f1a86c6",
          personalisation: {
            unlock_link: unlock_url
          }
        }
      end
    end
  end
end
