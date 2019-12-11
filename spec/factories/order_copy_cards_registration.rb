# frozen_string_literal: true

FactoryBot.define do
  factory :order_copy_cards_registration, class: WasteCarriersEngine::OrderCopyCardsRegistration do
    initialize_with { new(reg_identifier: create(:registration, :has_required_data, :is_active).reg_identifier) }

    trait :has_finance_details do
      temp_cards { 1 }
      finance_details { build(:finance_details, :has_copy_cards_order) }
    end
  end
end
