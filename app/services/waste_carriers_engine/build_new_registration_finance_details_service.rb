# frozen_string_literal: true

module WasteCarriersEngine
  class BuildNewRegistrationFinanceDetailsService < BaseService
    attr_reader :transient_registration

    def run(transient_registration:, payment_method:)
      @transient_registration = transient_registration

      finance_details = FinanceDetails.new
      finance_details.transient_registration = transient_registration

      finance_details.orders ||= []
      finance_details.orders << new_registration_order(payment_method)

      finance_details.update_balance
      finance_details.save!
    end

    private

    def new_registration_order(payment_method)
      order = Order.new_order_for(transient_registration.contact_email)

      order.order_items = []

      order.order_items << OrderItem.new_registration_item if transient_registration.upper_tier?

      if transient_registration.temp_cards&.positive?
        order.order_items << OrderItem.new_copy_cards_item(transient_registration.temp_cards)
      end

      order.set_description
      order.total_amount = order.order_items.sum(&:amount)

      order.add_bank_transfer_attributes if payment_method == :bank_transfer
      order.add_worldpay_attributes if payment_method == :worldpay

      order
    end
  end
end
