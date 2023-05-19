# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: "WasteCarriersEngine::Payment" do
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
  end
end
