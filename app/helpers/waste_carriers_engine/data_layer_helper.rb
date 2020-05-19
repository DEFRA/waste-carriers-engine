# frozen_string_literal: true

module WasteCarriersEngine
  module DataLayerHelper
    class UnexpectedSubtypeError < StandardError; end

    def data_layer(transient_registration)
      output = []

      data_layer_hash(transient_registration).each do |key, value|
        output << "'#{key}': '#{value}'"
      end

      output.join(",").html_safe
    end

    private

    def data_layer_hash(transient_registration)
      {
        journey: data_layer_value_for_journey(transient_registration)
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
      else
        raise UnexpectedSubtypeError, "No user journey found for #{subtype_name}"
      end
    end
  end
end
