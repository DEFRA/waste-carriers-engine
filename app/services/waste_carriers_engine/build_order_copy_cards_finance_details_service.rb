# frozen_string_literal: true

module WasteCarriersEngine
  class BuildOrderCopyCardsFinanceDetailsService < BaseBuildFinanceDetailsService

    def build_order_items
      [OrderItem.new_copy_cards_item(cards_count)]
    end
  end
end
