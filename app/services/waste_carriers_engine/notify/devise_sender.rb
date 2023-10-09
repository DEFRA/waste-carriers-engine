module WasteCarriersEngine
  module Notify
    class DeviseSender
      include WasteCarriersEngine::ApplicationHelper
      include ActionView::Helpers::NumberHelper

      def run(template:, record:, opts:)
        return unless record&.email.present?

        @record = record
        @token = opts[:token]

        client = Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key)

        client.send_email(notify_options)
      end
    end
  end
end
