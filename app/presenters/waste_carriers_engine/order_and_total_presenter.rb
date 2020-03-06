# frozen_string_literal: true

module WasteCarriersEngine
  class OrderAndTotalPresenter < BasePresenter
    LOCALES_KEY = ".waste_carriers_engine.shared.order_and_total"

    def order_items
      items = []

      transient_registration.finance_details.orders.first.order_items.each do |item|
        items << add_order_item(item)
      end

      items
    end

    def total_cost
      transient_registration.finance_details.balance
    end

    private

    def add_order_item(item)
      formatted_item = {}

      formatted_item[:cost] = item.amount
      formatted_item[:description] = description_for(item)

      formatted_item
    end

    def description_for(item)
      case item.type
      when OrderItem::TYPES[:renew]
        description_for_renew
      when OrderItem::TYPES[:edit]
        description_for_edit
      when OrderItem::TYPES[:copy_cards]
        description_for_copy_cards
      when OrderItem::TYPES[:charge_adjust]
        description_for_charge_adjust
      end
    end

    def description_for_renew
      I18n.t("#{LOCALES_KEY}.item_descriptions.renew")
    end

    def description_for_edit
      I18n.t("#{LOCALES_KEY}.item_descriptions.edit")
    end

    def description_for_copy_cards
      I18n.t("#{LOCALES_KEY}.item_descriptions.copy_cards", count: transient_registration.temp_cards)
    end

    def description_for_charge_adjust
      I18n.t("#{LOCALES_KEY}.item_descriptions.charge_adjust")
    end
  end
end
