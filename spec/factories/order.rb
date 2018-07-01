FactoryBot.define do
  factory :order, class: WasteCarriersEngine::Order do
    trait :has_required_data do
      order_items do
        [WasteCarriersEngine::OrderItem.new_renewal_item,
         WasteCarriersEngine::OrderItem.new_copy_cards_item(2)]
      end

      total_amount { order_items.sum { |item| item[:amount] } }
    end
  end
end
