class Payment
  include Mongoid::Document

  embedded_in :financeDetails

  # TODO: Confirm types
  # TODO: Confirm if all of these are needed
  field :orderKey, as: :order_key,                              type: Integer
  field :amount,                                                type: Integer
  field :currency,                                              type: String
  field :mac_code,                                              type: String
  field :dateReceived, as: :date_received,                      type: DateTime
  field :dateEntered, as: :date_entered,                        type: DateTime
  field :dateReceived_year, as: :date_received_year,            type: Integer # Not sure if this is required
  field :dateReceived_month, as: :date_received_month,          type: Integer # Not sure if this is required
  field :dateReceived_day, as: :date_received_day,              type: Integer # Not sure if this is required
  field :registrationReference, as: :registration_reference,    type: String
  field :worldPayPaymentStatus, as: :world_pay_payment_status,  type: String
  field :updatedByUser, as: :updated_by_user,                   type: String
  field :comment,                                               type: String
  field :paymentType, as: :payment_type,                        type: String
  field :manualPayment, as: :manual_payment,                    type: String
end
