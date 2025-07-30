# frozen_string_literal: true

require "notifications/client"

module WasteCarriersEngine
  module Notify
    class RegistrationConfirmationLetterService < BaseService
      include WasteCarriersEngine::ApplicationHelper
      include WasteCarriersEngine::CanRecordCommunication

      LOWER_TIER_TEMPLATE_ID = "e144cc0c-8903-434f-97a0-c798fcd35beb"
      LOWER_TIER_COMMS_LABEL = "Lower tier waste carrier registration letter V2 " \
                               "(with cert creation date and duty of care)"
      UPPER_TIER_TEMPLATE_ID = "06bfc531-6a39-42ec-8466-eba1041fb61b"
      UPPER_TIER_COMMS_LABEL = "Upper tier waste carrier registration letter V2 " \
                               "(with cert creation date and duty of care)"
      NOTIFICATION_TYPE = "letter"

      def run(registration:)
        @registration = registration

        client = Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key)

        client.send_letter(template_id: template_id,
                           reference: @registration.reg_identifier,
                           personalisation: personalisation).tap do |response|
                             if response.instance_of?(Notifications::Client::ResponseNotification)
                               create_communication_record
                             end
                           end
      end

      private

      def notification_type
        NOTIFICATION_TYPE
      end

      def template_id
        @registration.lower_tier? ? LOWER_TIER_TEMPLATE_ID : UPPER_TIER_TEMPLATE_ID
      end

      def comms_label
        @registration.lower_tier? ? LOWER_TIER_COMMS_LABEL : UPPER_TIER_COMMS_LABEL
      end

      def personalisation
        return base_personalisation if @registration.lower_tier?

        base_personalisation # upper_tier
          .merge(
            {
              expiry_date: expiry_date,
              registration_type: registration_type
            }
          )
      end

      def base_personalisation
        {
          contact_name: contact_name,
          reg_identifier: @registration.reg_identifier,
          company_name: company_name,
          registered_address: registered_address,
          phone_number: @registration.phone_number,
          date_registered: date_registered,
          certificate_creation_date: Date.today.to_s(:standard)
        }.merge(address_lines)
      end

      def contact_name
        "#{@registration.first_name} #{@registration.last_name}"
      end

      def company_name
        @registration.entity_display_name
      end

      def address_lines
        address_values = [
          contact_name,
          displayable_address(@registration.contact_address)
        ].flatten

        address_hash = {}

        address_values.each_with_index do |value, index|
          line_number = index + 1
          address_hash[:"address_line_#{line_number}"] = value
        end

        address_hash
      end

      def registered_address
        displayable_address(@registration.contact_address).join(", ")
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s(:standard)
      end

      def registration_type
        return unless @registration.upper_tier?

        I18n.t(
          "waste_carriers_engine.registration_type.upper.#{@registration.registration_type}"
        )
      end

      def expiry_date
        @registration.expires_on.in_time_zone("London").to_date.to_s(:standard)
      end
    end
  end
end
