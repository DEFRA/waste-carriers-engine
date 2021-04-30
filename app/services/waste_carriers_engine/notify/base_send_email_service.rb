# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class BaseSendEmailService < BaseService
      include WasteCarriersEngine::ApplicationHelper
      include ActionView::Helpers::NumberHelper

      def run(registration:, order: nil)
        @registration = registration
        @order = order

        client = Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key)

        client.send_email(notify_options)
      end

      def registration_type
        return unless @registration.upper_tier?

        I18n.t(
          "waste_carriers_engine.registration_type.upper.#{@registration.registration_type}"
        )
      end
    end
  end
end
