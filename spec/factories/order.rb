# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: WasteCarriersEngine::Order do
    trait :has_required_data do
      order_items do
        [WasteCarriersEngine::OrderItem.new_renewal_item,
         WasteCarriersEngine::OrderItem.new_copy_cards_item(1)]
      end
      total_amount { order_items.sum { |item| item[:amount] } }
    end

    trait :has_pending_worldpay_status do
      has_required_data

      world_pay_status { "SENT_FOR_AUTHORISATION" }
    end

    trait :has_copy_cards_item do
      date_created { Time.now }

      order_items do
        [WasteCarriersEngine::OrderItem.new_copy_cards_item(1)]
      end
      total_amount { order_items.sum { |item| item[:amount] } }
    end

    trait :has_type_change_item do
      date_created { Time.now }

      order_items do
        [WasteCarriersEngine::OrderItem.new_type_change_item]
      end
      total_amount { order_items.sum { |item| item[:amount] } }
    end
  end
end
