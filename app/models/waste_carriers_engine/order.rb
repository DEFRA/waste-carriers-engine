module WasteCarriersEngine
  class Order
    include Mongoid::Document

    embedded_in :finance_details, class_name: "WasteCarriersEngine::FinanceDetails"
    embeds_many :order_items,     class_name: "WasteCarriersEngine::OrderItem", store_as: "orderItems"

    accepts_nested_attributes_for :order_items

    field :orderId, as: :order_id,                   type: String
    field :orderCode, as: :order_code,               type: String
    field :paymentMethod, as: :payment_method,       type: String
    field :merchantId, as: :merchant_id,             type: String
    field :totalAmount, as: :total_amount,           type: Integer
    field :currency,                                 type: String
    field :dateCreated, as: :date_created,           type: DateTime
    field :worldPayStatus, as: :world_pay_status,    type: String
    field :dateLastUpdated, as: :date_last_updated,  type: DateTime
    field :updatedByUser, as: :updated_by_user,      type: String
    field :description,                              type: String
    field :amountType, as: :amount_type,             type: String
    field :exception,                                type: String
    field :manualOrder, as: :manual_order,           type: String
    field :order_item_reference,                     type: String

    def self.new_order(transient_registration, method, current_user)
      order = Order.new

      card_count = transient_registration.temp_cards

      order[:order_id] = order.generate_id
      order[:order_code] = order[:order_id]
      order[:currency] = "GBP"

      order[:date_created] = Time.current
      order[:date_last_updated] = order[:date_created]
      order[:updated_by_user] = current_user.email

      order[:order_items] = [OrderItem.new_renewal_item]
      order[:order_items] << OrderItem.new_type_change_item if transient_registration.registration_type_changed?
      order[:order_items] << OrderItem.new_copy_cards_item(card_count) if card_count.positive?

      order.generate_description

      order[:total_amount] = order[:order_items].sum { |item| item[:amount] }

      order.add_bank_transfer_attributes if method == :bank_transfer
      order.add_worldpay_attributes if method == :worldpay

      order
    end

    def self.valid_world_pay_status?(response_type, status)
      allowed_statuses = {
        success: ["AUTHORISED"],
        failure: ["EXPIRED", "REFUSED"],
        pending: ["SENT_FOR_AUTHORISATION", "SHOPPER_REDIRECTED"],
        cancel: ["CANCELLED"],
        error: ["ERROR"]
      }
      allowed_statuses[response_type].include?(status)
    end

    def add_bank_transfer_attributes
      self.payment_method = "OFFLINE"
    end

    def add_worldpay_attributes
      self.payment_method = "ONLINE"
      self.world_pay_status = "IN_PROGRESS"
      self.merchant_id = Rails.configuration.worldpay_merchantcode
    end

    def generate_id
      Time.now.to_i.to_s
    end

    def generate_description
      self.description = order_items.map(&:description).join(", plus ")
    end

    def update_after_worldpay(status)
      self.world_pay_status = status
      self.date_last_updated = Time.current
      save!
    end
  end
end
