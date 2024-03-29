# frozen_string_literal: true

module WasteCarriersEngine
  class BuildNewRegistrationFinanceDetailsService < BaseBuildFinanceDetailsService

    private

    def build_order_items
      order_items = []

      order_items << OrderItem.new_registration_item if transient_registration.upper_tier?

      if transient_registration.temp_cards&.positive?
        order_items << OrderItem.new_copy_cards_item(transient_registration.temp_cards)
      end

      order_items
    end
  end
end
