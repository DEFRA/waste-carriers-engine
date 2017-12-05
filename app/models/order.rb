class Order
  include Mongoid::Document

  embedded_in :financeDetails
  embeds_many :orderItems

  accepts_nested_attributes_for :orderItems

  # TODO: Confirm types
  # TODO: Confirm if all of these are actually required
  field :orderId, as: :order_id,                   type: String
  field :orderCode, as: :order_code,               type: Integer
  field :paymentMethod, as: :payment_method,       type: String
  field :merchantId, as: :merchant_id,             type: String
  field :totalAmount, as: :total_amount,           type: Integer # TODO: Confirm
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
end
