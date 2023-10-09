# frozen_string_literal: true

FactoryBot.define do
  factory :new_registration, class: "WasteCarriersEngine::NewRegistration" do
    metaData { association :metaData, strategy: :build }

    trait :has_required_data do
      location { "england" }
      declared_convictions { "no" }
      temp_cards { 1 }
      business_type { "limitedCompany" }
      contact_email { "foo@example.com" }
      first_name { "Jane" }
      last_name { "Doe" }
      metaData { association :metaData, route: "DIGITAL", strategy: :build }

      temp_check_your_tier { "unknown" }
      sequence :reg_identifier

      has_addresses
      has_postcode
      has_key_people
      upper

      after(:build, :create) do |registration|
        registration.prepare_for_payment(:govpay, nil)
      end
    end

    trait :has_pending_govpay_status do
      finance_details { association :finance_details, :has_pending_govpay_order, strategy: :build }
    end

    trait :has_required_lower_tier_data do
      location { "england" }
      declared_convictions { "no" }

      metaData { association :metaData, route: "DIGITAL", strategy: :build }

      sequence :reg_identifier

      has_addresses
      has_postcode
      has_key_people
      lower
    end

    trait :requires_conviction_check do
      key_people { [association(:key_person, :matched_conviction_search_result, strategy: :build)] }
      conviction_search_result { association :conviction_search_result, :match_result_yes, strategy: :build }
      conviction_sign_offs { [association(:conviction_sign_off, strategy: :build)] }
    end

    trait :upper do
      tier { WasteCarriersEngine::NewRegistration::UPPER_TIER }
    end

    trait :has_paid_finance_details do
      finance_details { association :finance_details, :has_paid_order_and_payment, strategy: :build }
    end

    trait :has_key_people do
      key_people do
        [association(:key_person, :has_required_data, :unmatched_conviction_search_result, :main, strategy: :build),
         association(:key_person, :has_required_data, :unmatched_conviction_search_result, :relevant, strategy: :build)]
      end
    end

    trait :declared_convictions do
      declared_convictions { "yes" }
    end

    trait :has_postcode do
      temp_company_postcode { "BS1 5AH" }
      temp_contact_postcode { "BS1 5AH" }
    end

    trait :lower do
      tier { WasteCarriersEngine::NewRegistration::LOWER_TIER }
    end

    trait :has_addresses do
      addresses do
        [association(:address, :has_required_data, :registered, :from_os_places, strategy: :build),
         association(:address, :has_required_data, :contact, :from_os_places, strategy: :build)]
      end
    end

    trait :has_registered_address do
      addresses { [association(:address, :has_required_data, :registered, :from_os_places, strategy: :build)] }
    end
  end
end
