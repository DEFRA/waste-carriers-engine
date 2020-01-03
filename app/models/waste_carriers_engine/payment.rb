# frozen_string_literal: true

module WasteCarriersEngine
  class Payment
    include Mongoid::Document
    include CanHavePaymentType

    embedded_in :finance_details, class_name: "WasteCarriersEngine::FinanceDetails"

    field :orderKey, as: :order_key,                              type: String
    field :amount,                                                type: Integer
    field :currency,                                              type: String, default: "GBP"
    field :mac_code,                                              type: String
    field :dateReceived, as: :date_received,                      type: Date
    field :dateEntered, as: :date_entered,                        type: DateTime
    field :dateReceived_year, as: :date_received_year,            type: Integer
    field :dateReceived_month, as: :date_received_month,          type: Integer
    field :dateReceived_day, as: :date_received_day,              type: Integer
    field :registrationReference, as: :registration_reference,    type: String
    field :worldPayPaymentStatus, as: :world_pay_payment_status,  type: String
    field :updatedByUser, as: :updated_by_user,                   type: String
    field :comment,                                               type: String

    scope :refundable, (lambda do
      where(
        payment_type: {
          "$in" => [CASH, CHEQUE, POSTALORDER, BANKTRANSFER, WORLDPAY, WORLDPAY_MISSED]
        }
      )
    end)

    def self.new_from_worldpay(order, current_user)
      payment = Payment.new

      payment[:order_key] = order[:order_code]
      payment[:amount] = order[:total_amount]
      payment[:currency] = "GBP"
      payment[:payment_type] = "WORLDPAY"
      payment[:registration_reference] = "Worldpay"
      payment[:comment] = "Paid via Worldpay"
      payment[:updated_by_user] = current_user.email
      payment.finance_details = order.finance_details

      payment
    end

    def self.new_from_non_worldpay(params, order)
      payment = Payment.new

      payment[:amount] = params[:amount]
      payment[:comment] = params[:comment]
      payment[:currency] = "GBP"
      payment[:date_entered] = Date.current
      payment[:date_received] = params[:date_received]
      payment[:date_received_day] = params[:date_received_day]
      payment[:date_received_month] = params[:date_received_month]
      payment[:date_received_year] = params[:date_received_year]
      payment[:order_key] = order[:order_code]
      payment[:payment_type] = params[:payment_type]
      payment[:registration_reference] = params[:registration_reference]
      payment[:updated_by_user] = params[:updated_by_user]

      payment.finance_details = order.finance_details

      payment
    end

    def update_after_worldpay(params)
      self.world_pay_payment_status = params[:paymentStatus]
      self.mac_code = params[:mac]

      self.date_received = Date.current
      self.date_entered = date_received
      self.date_received_year = date_received.strftime("%Y").to_i
      self.date_received_month = date_received.strftime("%-m").to_i
      self.date_received_day = date_received.strftime("%-d").to_i
      save!
    end
  end
end
