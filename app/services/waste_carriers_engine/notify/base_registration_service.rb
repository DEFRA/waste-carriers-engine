# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class BaseRegistrationService < BaseService
      def run(registration:)
        @registration = registration

        client = Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key)

        client.send_email(notify_options)
      end

      private

      def registered_address
        displayable_address(@registration.registered_address).join(", ")
      end
    end
  end
end
