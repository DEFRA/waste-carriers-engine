# frozen_string_literal: true

FactoryBot.define do
  factory :new_registration, class: WasteCarriersEngine::NewRegistration do
    trait :upper do
      tier { WasteCarriersEngine::NewRegistration::UPPER_TIER }
    end

    trait :lower do
      tier { WasteCarriersEngine::NewRegistration::LOWER_TIER }
    end
  end
end
