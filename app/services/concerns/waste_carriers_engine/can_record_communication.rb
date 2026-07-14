# frozen_string_literal: true

require "notifications/client"

module WasteCarriersEngine
  module CanRecordCommunication
    # Default until delivery statuses are fetched from Notify (RUBY-4284)
    DEFAULT_DELIVERY_STATUS = "sent"

    private

    def send_with_communication_record(client, notify_method, options)
      response = client.public_send(notify_method, options)
      if response.instance_of?(Notifications::Client::ResponseNotification)
        create_communication_record(response: response)
      end
      response
    rescue Notifications::Client::RequestError => e
      create_communication_record(delivery_status: e.message)
      raise
    end

    def communication_record_attributes(response: nil, delivery_status: nil)
      {
        notify_template_id: template_id,
        notification_id: response&.id,
        notification_type: notification_type,
        comms_label: comms_label,
        sent_at: Time.now.utc,
        sent_to: recipient,
        subject: response&.content&.fetch("subject", nil),
        content: response&.content&.fetch("body", nil),
        delivery_status: delivery_status || (DEFAULT_DELIVERY_STATUS if response)
      }
    end

    def template_id
      raise NotImplementedError, "You must implement template_id for CanRecordCommunication"
    end

    def comms_label
      raise NotImplementedError, "You must implement comms_label for CanRecordCommunication"
    end

    def notification_type
      raise NotImplementedError, "You must implement notification_type for CanRecordCommunication"
    end

    def recipient
      case notification_type
      when "letter"
        [recipient_name, displayable_address(@registration.contact_address)].flatten.join(", ")
      when "sms"
        @registration.phone_number
      else
        @registration.contact_email
      end
    end

    def recipient_address
      @registration.contact_name
    end

    def recipient_name
      [@registration.first_name, @registration.last_name].join(" ")
    end

    def create_communication_record(response: nil, delivery_status: nil)
      @registration.communication_records.create(
        communication_record_attributes(response: response, delivery_status: delivery_status)
      )
    end
  end
end
