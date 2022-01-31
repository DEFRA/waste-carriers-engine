# frozen_string_literal: true

# This collection duplicates order item details in a simple flat structure
# to facilitate queries for reports and exports. The source data structure
# has multiple embedded layers which leads to complex / brittle query logic.
module WasteCarriersEngine
  class OrderItemLog
    include Mongoid::Document

    field :registration_id, type: BSON::ObjectId
    field :order_id,        type: BSON::ObjectId
    field :order_item_id,   type: BSON::ObjectId
    field :activated_at,    type: DateTime
    field :type,            type: String

    # A single OrderItem can generate multiple OrderItemLogs.
    def self.create_from(order_item)
      order_item.quantity.times do
        create!(order_item)
      end
    end

    private

    def initialize(order_item)
      super()
      order = order_item.order
      registration = order.finance_details.registration

      self.order_item_id   = order_item.id
      self.type            = order_item.type
      self.order_id        = order.id
      self.registration_id = registration.id
      self.activated_at    = registration.metaData.dateActivated
    end

  end
end
