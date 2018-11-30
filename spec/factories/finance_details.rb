# frozen_string_literal: true

FactoryBot.define do
  factory :finance_details, class: WasteCarriersEngine::FinanceDetails do
    trait :has_required_data do
      balance { 10_000 }
      orders { [] }
      payments { [] }
    end

    trait :has_order do
      orders { [build(:order, :has_required_data)] }
    end

    trait :has_order_and_payment do
      orders { [build(:order, :has_required_data)] }
      payments { [build(:payment)] }
    end
  end
end
