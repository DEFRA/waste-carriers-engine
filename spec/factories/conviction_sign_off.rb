FactoryBot.define do
  factory :conviction_sign_off, class: WasteCarriersEngine::ConvictionSignOff do
    confirmed { "no" }
  end
end
