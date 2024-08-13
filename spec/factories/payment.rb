# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: "WasteCarriersEngine::Payment" do
    order_key { SecureRandom.uuid.split("-").last }
    amount { Faker::Number.number(digits: 4) }

    trait :worldpay do
      payment_type { "WORLDPAY" }
    end

    trait :govpay do
      payment_type { "GOVPAY" }
    end

    trait :bank_transfer do
      payment_type { "BANKTRANSFER" }
    end

    trait :govpay_refund do
      payment_type { WasteCarriersEngine::Payment::REFUND }
      govpay_id { SecureRandom.hex(22) }
    end

    trait :govpay_refund_pending do
      payment_type { WasteCarriersEngine::Payment::REFUND }
      govpay_id { SecureRandom.hex(22) }
      govpay_payment_status { WasteCarriersEngine::Payment::STATUS_SUBMITTED }
    end
  end
end
