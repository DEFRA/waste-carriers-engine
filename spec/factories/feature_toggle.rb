# frozen_string_literal: true

FactoryBot.define do
  factory :feature_toggle, class: WasteCarriersEngine::FeatureToggle do
    key { "test-feature" }

    active { false }

    trait :govpay_payments do
      key { :govpay_payments }
      active { true }
    end
  end
end
