# frozen_string_literal: true

FactoryBot.define do
  factory :new_registration, class: WasteCarriersEngine::NewRegistration do
    metaData { build(:metaData) }

    trait :has_required_data do
      location { "england" }
      declared_convictions { "no" }
      temp_cards { 1 }

      metaData { build(:metaData, route: "DIGITAL") }

      sequence :reg_identifier

      has_addresses
      has_postcode
      has_key_people
      upper

      after(:build, :create) do |registration|
        registration.prepare_for_payment(:worldpay, nil)
      end
    end

    trait :upper do
      tier { WasteCarriersEngine::NewRegistration::UPPER_TIER }
    end

    trait :has_paid_finance_details do
      finance_details { build(:finance_details, :has_paid_order_and_payment) }
    end

    trait :has_key_people do
      key_people do
        [build(:key_person, :has_required_data, :unmatched_conviction_search_result, :main),
         build(:key_person, :has_required_data, :unmatched_conviction_search_result, :relevant)]
      end
    end

    trait :has_postcode do
      temp_company_postcode { "BS1 5AH" }
      temp_contact_postcode { "BS1 5AH" }
    end

    trait :lower do
      tier { WasteCarriersEngine::NewRegistration::LOWER_TIER }
    end

    trait :has_addresses do
      addresses { [build(:address, :has_required_data, :registered, :from_os_places), build(:address, :has_required_data, :contact, :from_os_places)] }
    end
  end
end
