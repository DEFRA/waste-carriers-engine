# frozen_string_literal: true

module WasteCarriersEngine
  class BuildEditFinanceDetailsService < BaseService
    def run(user:, transient_registration:, payment_method:)
      finance_details = FinanceDetails.new
      finance_details.transient_registration = transient_registration
      order = set_up_edit_order(user, payment_method, transient_registration)

      finance_details[:orders] ||= []
      finance_details[:orders] << order

      finance_details.update_balance
      finance_details.save!
    end

    private

    def set_up_edit_order(user, payment_method, transient_registration)
      order = Order.new_order_for(user)
      new_item = OrderItem.new_type_change_item if transient_registration.registration_type_changed?

      order[:order_items] = [new_item]

      order.set_description

      order[:total_amount] = new_item[:amount]

      order.add_bank_transfer_attributes if payment_method == :bank_transfer
      order.add_worldpay_attributes if payment_method == :worldpay
      order.add_govpay_attributes if payment_method == :govpay

      order
    end
  end
end
