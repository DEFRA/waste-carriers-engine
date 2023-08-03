# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RenewalConfirmationLetterService < BaseService
      include WasteCarriersEngine::ApplicationHelper

      def run(registration:)
        @registration = registration

        client = Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key)

        client.send_letter(template_id: template,
                           reference: @registration.reg_identifier,
                           personalisation: personalisation)
      end

      private

      def template
        "95af7082-1906-4ff1-bef5-f85fe4a5a01c"
      end

      def personalisation
        {
          registration_type: registration_type,
          contact_name: contact_name,
          reg_identifier: @registration.reg_identifier,
          company_name: company_name,
          registered_address: registered_address,
          phone_number: @registration.phone_number,
          date_registered: date_registered,
          expiry_date: expiry_date,
          certificate_creation_date: Date.today.to_s(:standard)
        }.merge(address_lines)
      end

      def address_lines
        address_values = [
          contact_name,
          displayable_address(@registration.contact_address)
        ].flatten

        address_hash = {}

        address_values.each_with_index do |value, index|
          line_number = index + 1
          address_hash["address_line_#{line_number}".to_sym] = value
        end

        address_hash
      end

      def registered_address
        displayable_address(@registration.contact_address).join(", ")
      end

      def contact_name
        "#{@registration.first_name} #{@registration.last_name}"
      end

      def company_name
        @registration.entity_display_name
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s(:standard)
      end

      def expiry_date
        @registration.expires_on.in_time_zone("London").to_date.to_s(:standard)
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
