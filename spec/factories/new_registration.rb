# frozen_string_literal: true

FactoryBot.define do
  factory :new_registration, class: WasteCarriersEngine::NewRegistration do
    trait :upper do
      tier { WasteCarriersEngine::NewRegistration::UPPER_TIER }
    end

    trait :lower do
      tier { WasteCarriersEngine::NewRegistration::LOWER_TIER }
    end

    trait :has_addresses do
      addresses { [build(:address, :has_required_data, :registered, :from_os_places), build(:address, :has_required_data, :contact, :from_os_places)] }
    end
  end
end
