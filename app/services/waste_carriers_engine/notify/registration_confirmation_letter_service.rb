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
                           personalisation: personalisation)
      end

      private

      def template
        "92817aa7-6289-4837-a033-96d287644cb3"
      end

      def personalisation
        if @registration.upper_tier?
          base_personalisation.merge(upper_tier_personalisation)
        else
          # this will be implemented in #1409 (lower tier confirmation letters)
          base_personalisation
        end
      end

      def base_personalisation
        {
          contact_name: contact_name,
          reg_identifier: @registration.reg_identifier,
          company_name: @registration.company_name,
          registered_address: registered_address,
          phone_number: @registration.phone_number,
          date_registered: date_registered
        }.merge(address_lines)
      end

      def upper_tier_personalisation
        return {} unless @registration.upper_tier?

        {
          expiry_date: expiry_date,
          registration_type: registration_type
        }
      end

      def contact_name
        "#{@registration.first_name} #{@registration.last_name}"
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
