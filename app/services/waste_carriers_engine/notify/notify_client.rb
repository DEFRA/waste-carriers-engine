# frozen_string_literal: true

require "notifications/client"

module WasteCarriersEngine
  module Notify
    # Add reference to every message sent to Notify
    # to allow messages to be traced back to registrations
    class NotifyClient
      def initialize(reference:, client: Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key))
        @reference = reference
        @client = client
      end

      def send_email(args) = @client.send_email(with_reference(args))
      def send_sms(args) = @client.send_sms(with_reference(args))
      def send_letter(args) = @client.send_letter(with_reference(args))

      private

      def with_reference(args)
        args.reverse_merge(reference: @reference)
      end
    end
  end
end
