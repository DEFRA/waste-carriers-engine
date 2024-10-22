# frozen_string_literal: true

module WasteCarriersEngine
  class BaseBuildFinanceDetailsService < BaseService
    attr_reader :transient_registration, :user, :cards_count

    def run(transient_registration:, payment_method:, user: nil, cards_count: 0)
      @transient_registration = transient_registration
      @user = user
      @cards_count = cards_count

      # Handle race condition if multiple browsers submit the order:
      return transient_registration.finance_details if transient_registration.finance_details&.orders.present?

      finance_details = FinanceDetails.new
      finance_details.transient_registration = transient_registration

      finance_details.orders ||= []
      finance_details.orders << build_order(payment_method)

      finance_details.update_balance
      finance_details.save!
      finance_details
    end

    private

    def build_order(payment_method)
      order = Order.new_order_for(order_email)

      order.order_items = build_order_items

      order.set_description
      order.total_amount = order.order_items.sum(&:amount)

      order.add_bank_transfer_attributes if payment_method == :bank_transfer
      order.add_govpay_attributes if payment_method == :govpay

      order
    end

    def order_email
      user.present? ? user.email : transient_registration.contact_email
    end

    def build_order_items
      raise NotImplementedError
    end
  end
end
