# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class DeviseSender
      include WasteCarriersEngine::ApplicationHelper
      include ActionView::Helpers::NumberHelper

      def run(template:, record:, opts:)
        service_class = service_for_template(template)
        service = service_class.new

        service.send_email(record, opts[:token])
      end

      def send_email(record, token)
        client.send_email(notify_options(record, token))
      end

      private

      def service_for_template(template)
        case template
        when :reset_password_instructions
          ResetPasswordInstructionsEmailService
        when :unlock_instructions
          UnlockInstructionsEmailService
        else
          raise ArgumentError, "Unknown email template: #{template}"
        end
      end

      def client
        @client ||= Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key)
      end
    end
  end
end
