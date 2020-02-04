# frozen_string_literal: true

module WasteCarriersEngine
  class OrderItem
    include Mongoid::Document

    embedded_in :order, class_name: "WasteCarriersEngine::Order"

    TYPES = HashWithIndifferentAccess.new(
      renew: "RENEW",
      edit: "EDIT",
      copy_cards: "COPY_CARDS",
      charge_adjust: "CHARGE_ADJUST"
    )

    field :amount,                          type: Integer
    field :quantity,                        type: Integer
    field :currency,                        type: String, default: "GBP"
    field :lastUpdated, as: :last_updated,  type: DateTime
    field :description,                     type: String
    field :reference,                       type: String
    field :type,                            type: String

    def self.new_renewal_item
      order_item = OrderItem.base_order_item

      order_item.amount = Rails.configuration.renewal_charge
      order_item.description = "Renewal of registration"
      order_item.type = TYPES[:renew]
      order_item.quantity = 1

      order_item
    end

    def self.new_charge_adjust_item
      new(type: TYPES[:charge_adjust])
    end

    def self.new_type_change_item
      order_item = OrderItem.base_order_item

      order_item.amount = Rails.configuration.type_change_charge
      order_item.description = "changing carrier type during renewal"
      order_item.type = TYPES[:edit]
      order_item.quantity = 1

      order_item
    end

    def self.new_copy_cards_item(cards)
      order_item = OrderItem.base_order_item

      order_item.amount = cards * Rails.configuration.card_charge

      order_item.description = "#{cards} registration cards"
      order_item.description = "1 registration card" if cards == 1
      order_item.quantity = cards

      order_item.type = TYPES[:copy_cards]

      order_item
    end

    def self.base_order_item
      order_item = OrderItem.new
      order_item.currency = "GBP"
      order_item
    end
  end
end
