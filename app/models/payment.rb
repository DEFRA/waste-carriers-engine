class Payment
  include Mongoid::Document

  embedded_in :finance_details

  # TODO: Confirm types
  # TODO: Confirm if all of these are needed
  field :orderKey, as: :order_key,                              type: String
  field :amount,                                                type: Integer
  field :currency,                                              type: String
  field :mac_code,                                              type: String
  field :dateReceived, as: :date_received,                      type: Date
  field :dateEntered, as: :date_entered,                        type: Date
  field :dateReceived_year, as: :date_received_year,            type: Integer # Not sure if this is required
  field :dateReceived_month, as: :date_received_month,          type: Integer # Not sure if this is required
  field :dateReceived_day, as: :date_received_day,              type: Integer # Not sure if this is required
  field :registrationReference, as: :registration_reference,    type: String
  field :worldPayPaymentStatus, as: :world_pay_payment_status,  type: String
  field :updatedByUser, as: :updated_by_user,                   type: String
  field :comment,                                               type: String
  field :paymentType, as: :payment_type,                        type: String
  field :manualPayment, as: :manual_payment,                    type: String

  def self.new_from_worldpay(order)
    payment = Payment.new

    payment[:order_key] = order[:order_code]
    payment[:amount] = order[:total_amount]
    payment[:currency] = "GBP"
    payment[:payment_type] = "WORLDPAY"
    payment.finance_details = order.finance_details
    payment.save

    payment
  end

  def update_after_worldpay(params)
    self.world_pay_payment_status = params[:paymentStatus]
    self.date_received = Date.current
    self.date_received_year = date_received.strftime("%Y").to_i
    self.date_received_month = date_received.strftime("%-m").to_i
    self.date_received_day = date_received.strftime("%-d").to_i
    save
  end
end
