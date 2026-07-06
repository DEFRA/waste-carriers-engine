# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class BaseSendEmailService < BaseService
      include WasteCarriersEngine::ApplicationHelper
      include ActionView::Helpers::NumberHelper
      include WasteCarriersEngine::CanRecordCommunication

      NOTIFICATION_TYPE = "email"

      def run(registration:, order: nil, requester: nil)
        # AD registrations will not have a contact_mail
        return unless registration&.contact_email.present?

        @registration = registration
        @order = order
        @requester = requester

        client = Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key)
        send_with_communication_record(client, :send_email, notify_options)
      end

      private

      def registration_type
        return unless @registration.upper_tier?

        I18n.t(
          "waste_carriers_engine.registration_type.upper.#{@registration.registration_type}"
        )
      end

      def comms_label
        self.class::COMMS_LABEL
      end

      def template_id
        self.class::TEMPLATE_ID
      end

      def notification_type
        NOTIFICATION_TYPE
      end
    end
  end
end
