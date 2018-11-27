# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: WasteCarriersEngine::Payment do
    trait :worldpay do
      payment_type { "WORLDPAY" }
    end

    trait :bank_transfer do
      payment_type { "BANKTRANSFER" }
    end
  end
end
