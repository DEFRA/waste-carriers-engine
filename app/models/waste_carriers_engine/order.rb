# frozen_string_literal: true

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
    field :payment_uuid,                             type: String
    field :totalAmount, as: :total_amount,           type: Integer
    field :currency,                                 type: String
    field :dateCreated, as: :date_created,           type: DateTime
    field :worldPayStatus, as: :world_pay_status,    type: String
    field :govpayId, as: :govpay_id,                 type: String
    field :dateLastUpdated, as: :date_last_updated,  type: DateTime
    field :updatedByUser, as: :updated_by_user,      type: String
    field :description,                              type: String
    field :amountType, as: :amount_type,             type: String
    field :exception,                                type: String
    field :manualOrder, as: :manual_order,           type: String
    field :order_item_reference,                     type: String

    def self.new_order_for(user_email)
      order = Order.new

      order[:order_id] = order.generate_id
      order[:order_code] = order[:order_id]
      order[:currency] = "GBP"

      order[:date_created] = Time.current
      order[:date_last_updated] = order[:date_created]
      order[:updated_by_user] = user_email.is_a?(String) ? user_email : user_email&.email

      order
    end

    def govpay_status
      return nil unless govpay_id

      payment = finance_details.payments.find_by(govpay_id: govpay_id)
      payment&.govpay_payment_status
    end

    def add_bank_transfer_attributes
      self.payment_method = "OFFLINE"
    end

    def add_govpay_attributes
      self.payment_method = "ONLINE"
    end

    def generate_id
      Time.now.to_i.to_s
    end

    def set_description
      self.description = generate_description
    end

    def update_after_online_payment
      self.date_last_updated = Time.current
      save!
    end

    # Generate a uuid for the payment associated with this order, on demand
    def payment_uuid
      update_attributes!(payment_uuid: SecureRandom.uuid) unless self[:payment_uuid]

      self[:payment_uuid]
    end

    private

    def generate_description
      return unless order_items.any?

      description = order_items.map(&:description)
                               .join(", plus ")

      description[0] = description[0].capitalize

      description
    end
  end
end
