# frozen_string_literal: true

require "notifications/client"

module WasteCarriersEngine
  module Notify
    class RegistrationConfirmationLetterService < BaseService
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
        return "0ad5d154-9e44-4da7-8c1b-b4b14d1057cd" if @registration.lower_tier?

        "92817aa7-6289-4837-a033-96d287644cb3" # upper_tier
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
          date_registered: date_registered
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
          address_hash["address_line#{line_number}".to_sym] = value
        end

        address_hash
      end

      def registered_address
        displayable_address(@registration.contact_address).join(", ")
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s
      end

      def registration_type
        return unless @registration.upper_tier?

        I18n.t(
          "waste_carriers_engine.registration_type.upper.#{@registration.registration_type}"
        )
      end

      def expiry_date
        @registration.expires_on.in_time_zone("London").to_date.strftime("%e %B %Y").to_s
      end
    end
  end
end
