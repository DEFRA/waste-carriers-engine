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
    field :uuid,                                                  type: String
    field :moto,                                                  type: Boolean, default: false
    field :dateReceived, as: :date_received,                      type: Date
    field :dateEntered, as: :date_entered,                        type: DateTime
    field :dateReceived_year, as: :date_received_year,            type: Integer
    field :dateReceived_month, as: :date_received_month,          type: Integer
    field :dateReceived_day, as: :date_received_day,              type: Integer
    field :registrationReference, as: :registration_reference,    type: String
    field :worldPayPaymentStatus, as: :world_pay_payment_status,  type: String
    field :govpayPaymentStatus, as: :govpay_payment_status,       type: String
    field :updatedByUser, as: :updated_by_user,                   type: String
    field :comment,                                               type: String

    # for govpay payments and refunds, the unique govpay identifier:
    field :govpay_id,                                             type: String
    # for payments of type refund, the govpay id of the payment that was refunded:
    field :refunded_payment_govpay_id,                            type: String

    scope :refundable, -> { where(payment_type: { "$in" => RECEIVABLE_PAYMENT_TYPES }) }
    scope :reversible, -> { where(payment_type: { "$in" => RECEIVABLE_PAYMENT_TYPES }) }

    # Select payments where the type is not one of the online ones, or if it is, the status is AUTHORISED / success
    scope :except_online_not_authorised,
          lambda {
            where(
              "$or": [
                { payment_type: { "$nin" => %w[WORLDPAY GOVPAY REFUND] } },
                { "$and": [{ payment_type: "WORLDPAY" }, { world_pay_payment_status: "AUTHORISED" }] },
                { "$and": [{ payment_type: "GOVPAY" }, { govpay_payment_status: "success" }] },
                { "$and": [{ payment_type: "REFUND" }, { govpay_payment_status: "success" }] },
                { "$and": [{ payment_type: "REFUND" }, { govpay_payment_status: nil },
                           { world_pay_payment_status: nil }] }
              ]
            )
          }

    def self.new_from_online_payment(order, user_email)
      payment = Payment.new

      payment[:order_key] = order[:order_code]
      payment[:amount] = order[:total_amount]
      payment[:currency] = "GBP"
      payment[:updated_by_user] = user_email
      payment.finance_details = order.finance_details

      payment[:payment_type] = "GOVPAY"
      payment[:registration_reference] = "Govpay"
      payment[:comment] = "Paid via Govpay"
      payment[:uuid] = order.payment_uuid
      payment
    end

    def self.new_from_non_online_payment(params, order)
      payment = Payment.new(params.slice(:amount,
                                         :comment,
                                         :date_received,
                                         :date_received_day,
                                         :date_received_month,
                                         :date_received_year,
                                         :payment_type,
                                         :registration_reference,
                                         :updated_by_user))

      payment[:currency] = "GBP"
      payment[:date_entered] = Date.current
      payment[:order_key] = SecureRandom.uuid.split("-").last

      payment.finance_details = order.finance_details

      payment
    end

    def update_after_online_payment(params)
      self.govpay_payment_status = params[:govpay_status]
      self.govpay_id = params[:govpay_id]
      self.moto = WasteCarriersEngine.configuration.host_is_back_office?
      self.date_received = Date.current
      self.date_entered = date_received
      self.date_received_year = date_received.strftime("%Y").to_i
      self.date_received_month = date_received.strftime("%-m").to_i
      self.date_received_day = date_received.strftime("%-d").to_i
      save!
    end
  end
end
