# frozen_string_literal: true

FactoryBot.define do
  factory :finance_details, class: "WasteCarriersEngine::FinanceDetails" do
    trait :has_required_data do
      balance { 10_000 }
      orders { [] }
      payments { [] }
    end

    trait :has_pending_worldpay_order do
      has_required_data

      orders { [build(:order, :has_pending_worldpay_status)] }
    end

    trait :has_pending_govpay_order do
      has_required_data

      orders { [build(:order, :has_pending_govpay_status)] }
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

    trait :has_paid_orders_and_payments do
      orders do
        [
          build(:order, :has_required_data),
          build(:order, :has_copy_cards_item)
        ]
      end
      payments do
        [
          build(:payment, :bank_transfer, amount: 10_500),
          build(:payment, :bank_transfer, amount: 500),
          build(:payment, :bank_transfer, amount: 500)
        ]
      end
      after(:build, :create, &:update_balance)
    end

    trait :has_overpaid_order_and_payment_govpay do
      orders { [build(:order, :has_required_data)] }
      payments do
        [build(:payment, :govpay, govpay_payment_status: WasteCarriersEngine::Payment::STATUS_SUCCESS, amount: 100_500)]
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
