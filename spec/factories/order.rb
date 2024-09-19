# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: "WasteCarriersEngine::Order" do
    trait :has_required_data do
      order_items do
        [
          build(:order_item, :new_renewal_item),
          build(:order_item, :new_copy_cards_item)
        ]
      end
      total_amount { order_items.sum { |item| item[:amount] } }
    end

    trait :has_copy_cards_item do
      date_created { Time.now }

      order_items do
        [build(:order_item, :new_copy_cards_item)]
      end
      total_amount { order_items.sum { |item| item[:amount] } }
    end

    trait :has_type_change_item do
      date_created { Time.now }

      order_items do
        [build(:order_item, :new_type_change_item)]
      end
      total_amount { order_items.sum { |item| item[:amount] } }
    end
  end
end
