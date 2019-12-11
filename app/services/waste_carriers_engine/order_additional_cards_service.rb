# frozen_string_literal: true

module WasteCarriersEngine
  class OrderAdditionalCardsService < BaseService
    def run(cards_count:, user:, transient_registration:, payment_method:)
      finance_details = FinanceDetails.new
      finance_details.transient_registration = transient_registration
      order = additional_cards_order(user, cards_count, payment_method)

      finance_details[:orders] ||= []
      finance_details[:orders] << order

      finance_details.update_balance
      finance_details.save!
    end

    private

    def additional_cards_order(user, cards_count, payment_method)
      order = Order.new_order_for(user)
      new_item = OrderItem.new_copy_cards_item(cards_count)

      order[:order_items] = [new_item]

      order.generate_description

      order[:total_amount] = new_item[:amount]

      order.add_bank_transfer_attributes if payment_method == :bank_transfer
      order.add_worldpay_attributes if payment_method == :worldpay

      order
    end
  end
end
