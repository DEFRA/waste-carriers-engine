class FinanceDetails
  include Mongoid::Document

  embedded_in :registration
  embedded_in :past_registration
  embedded_in :transient_registration
  embeds_many :orders
  embeds_many :payments

  accepts_nested_attributes_for :orders, :payments

  # TODO: Confirm types
  field :balance, type: Integer

  validates :balance,
            presence: true

  def self.new_finance_details(transient_registration, method)
    finance_details = FinanceDetails.new
    finance_details.transient_registration = transient_registration
    finance_details[:orders] = [Order.new_order(transient_registration, method)]
    finance_details.update_balance
    finance_details.save!
    finance_details
  end

  def update_balance
    order_balance = orders.sum { |item| item[:total_amount] }
    payment_balance = payments.where(world_pay_payment_status: "AUTHORISED").sum { |item| item[:amount] }
    self.balance = order_balance - payment_balance
  end
end
