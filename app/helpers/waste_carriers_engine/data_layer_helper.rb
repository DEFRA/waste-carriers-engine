# frozen_string_literal: true

module WasteCarriersEngine
  module DataLayerHelper
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
      case transient_registration.class.name
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
      end
    end
  end
end
