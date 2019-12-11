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

    trait :has_copy_cards_order do
      orders { [build(:order, :has_copy_cards_item)] }
      after(:build, :create, &:update_balance)
    end

    trait :has_order_and_payment do
      orders { [build(:order, :has_required_data)] }
      payments { [build(:payment)] }
    end

    trait :has_paid_order_and_payment do
      orders { [build(:order, :has_required_data)] }
      payments do
        [
          build(:payment, :bank_transfer, amount: 10_500),
          build(:payment, :bank_transfer, amount: 500)
        ]
      end
      after(:build, :create, &:update_balance)
    end

    trait :has_outstanding_copy_card do
      orders { [build(:order, :has_required_data)] }
      payments { [build(:payment, :bank_transfer, amount: 10_500)] }
      after(:build, :create, &:update_balance)
    end
  end
end
