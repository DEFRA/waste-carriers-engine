# frozen_string_literal: true

module WasteCarriersEngine
  class OrderItem
    include Mongoid::Document

    embedded_in :order, class_name: "WasteCarriersEngine::Order"

    field :amount,                          type: Integer
    field :currency,                        type: String
    field :lastUpdated, as: :last_updated,  type: DateTime
    field :description,                     type: String
    field :reference,                       type: String
    field :type,                            type: String

    def self.new_renewal_item
      order_item = OrderItem.base_order_item

      order_item[:amount] = Rails.configuration.renewal_charge
      order_item[:description] = "Renewal of registration"
      order_item[:type] = "RENEW"

      order_item
    end

    def self.new_type_change_item
      order_item = OrderItem.base_order_item

      order_item[:amount] = Rails.configuration.type_change_charge
      order_item[:description] = "changing carrier type during renewal"
      order_item[:type] = "CHARGE_ADJUST"

      order_item
    end

    def self.new_copy_cards_item(cards)
      order_item = OrderItem.base_order_item

      order_item[:amount] = cards * Rails.configuration.card_charge
      order_item[:description] = "#{cards} registration cards"
      order_item[:type] = "COPY_CARDS"

      order_item
    end

    def self.base_order_item
      order_item = OrderItem.new
      order_item[:currency] = "GBP"
      order_item
    end
  end
end
