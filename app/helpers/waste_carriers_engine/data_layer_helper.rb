# frozen_string_literal: true

module WasteCarriersEngine
  module DataLayerHelper
    class UnexpectedSubtypeError < StandardError; end

    def data_layer(transient_registration)
      output = []

      data_layer_hash(transient_registration).each do |key, value|
        output << "'#{key}': '#{value}'"
      end

      output.join(", ").html_safe
    end

    private

    def data_layer_hash(transient_registration)
      {
        journey: data_layer_value_for_journey(transient_registration),
        tier: data_layer_value_for_tier(transient_registration)
      }
    end

    def data_layer_value_for_journey(transient_registration)
      subtype_name = transient_registration.class.name

      case subtype_name
      when "WasteCarriersEngine::CeasedOrRevokedRegistration"
        :cease_or_revoke
      when "WasteCarriersEngine::EditRegistration"
        :edit
      when "WasteCarriersEngine::NewRegistration"
        :new
      when "WasteCarriersEngine::OrderCopyCardsRegistration"
        :order_copy_cards
      when "WasteCarriersEngine::RenewingRegistration"
        :renew
      when "WasteCarriersEngine::DeregisteringRegistration"
        :deregister
      else
        raise UnexpectedSubtypeError, "No user journey found for #{subtype_name}"
      end
    end

    def data_layer_value_for_tier(transient_registration)
      if transient_registration.upper_tier?
        :upper
      elsif transient_registration.lower_tier?
        :lower
      else
        :unknown
      end
    end
  end
end
