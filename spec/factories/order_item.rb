# frozen_string_literal: true

FactoryBot.define do
  factory :order_item, class: "WasteCarriersEngine::OrderItem" do

    trait :new_renewal_item do
      currency { "GBP" }
      amount { Rails.configuration.renewal_charge }
      description { "renewal of registration" }
      type { "RENEW" }
      quantity { 1 }
    end

    trait :new_copy_cards_item do
      currency { "GBP" }
      amount { Rails.configuration.card_charge }
      description { "1 registration card" }
      type { "COPY_CARDS" }
      quantity { 1 }
    end

    trait :new_type_change_item do
      currency { "GBP" }
      amount { Rails.configuration.type_change_charge }
      description { "changing carrier type" }
      type { "EDIT" }
      quantity { 1 }
    end
  end
end
