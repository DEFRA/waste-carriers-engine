# frozen_string_literal: true

# This collection duplicates order item details in a simple flat structure
# to facilitate queries for reports and exports. The source data structure
# has multiple embedded layers which leads to complex / brittle query logic.
module WasteCarriersEngine
  class OrderItemLog
    include Mongoid::Document
    include CanCheckRegistrationStatus

    field :registration_id, type: BSON::ObjectId
    field :order_id,        type: BSON::ObjectId
    field :order_item_id,   type: BSON::ObjectId
    field :activated_at,    type: DateTime
    field :type,            type: String
    field :quantity,        type: Integer
    field :exported,        type: Boolean, default: false

    belongs_to :registration

    def active_registration?
      registration.active?
    end

    def self.create_from_registration(registration, activation_time = nil)
      registration.finance_details.orders.each do |order|
        order.order_items.each do |order_item|
          create_from_order_item(order_item, activation_time)
        end
      end
    end

    def self.create_from_order_item(order_item, activation_time = nil)
      order = order_item.order
      registration = order.finance_details.registration
      OrderItemLog.find_or_create_by(order_item_id: order_item.id) do |order_item_log|
        order_item_log.type            = order_item.type
        order_item_log.quantity        = order_item.quantity
        order_item_log.order_id        = order.id
        order_item_log.registration_id = registration.id
        order_item_log.activated_at    = activation_time || registration.metaData.dateActivated
      end
    end

  end
end
