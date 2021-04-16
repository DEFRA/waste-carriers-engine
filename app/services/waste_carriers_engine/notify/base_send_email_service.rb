# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class BaseSendEmailService < BaseService
      def run(registration:)
        @registration = registration

        client = Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key)

        client.send_email(notify_options)
      end
    end
  end
end
