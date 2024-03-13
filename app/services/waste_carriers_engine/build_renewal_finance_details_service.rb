# frozen_string_literal: true

module WasteCarriersEngine
  class BuildRenewalFinanceDetailsService < BaseBuildFinanceDetailsService

    private

    def build_order_items
      order_items = [OrderItem.new_renewal_item]
      order_items << OrderItem.new_type_change_item if transient_registration.registration_type_changed?

      if transient_registration.temp_cards&.positive?
        order_items << OrderItem.new_copy_cards_item(transient_registration.temp_cards)
      end

      order_items
    end
  end
end
