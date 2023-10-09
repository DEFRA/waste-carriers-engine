# frozen_string_literal: true

FactoryBot.define do
  factory :transient_registration, class: "WasteCarriersEngine::TransientRegistration" do
    trait :has_required_data do
      location { "england" }
      declared_convictions { "no" }
      temp_cards { 1 }

      has_postcode
    end

    trait :has_addresses do
      addresses do
        [association(:address, :has_required_data, :registered, :from_os_places, strategy: :build),
         association(:address, :has_required_data, :contact, :from_os_places, strategy: :build)]
      end
    end

    trait :has_registered_address do
      addresses do
        [association(:address, :has_required_data, :registered, :from_os_places, strategy: :build)]
      end
    end

    trait :has_postcode do
      temp_company_postcode { "BS1 5AH" }
      temp_contact_postcode { "BS1 5AH" }
    end

    trait :requires_conviction_check do
      key_people do
        [association(:key_person, :matched_conviction_search_result, strategy: :build)]
      end
      conviction_search_result { association(:conviction_search_result, :match_result_yes, strategy: :build) }
      conviction_sign_offs { [association(:conviction_sign_off, strategy: :build)] }
    end

    trait :has_unpaid_balance do
      finance_details { association(:finance_details, balance: 1000, strategy: :build) }
    end

    trait :has_paid_balance do
      finance_details { association(:finance_details, balance: 0, strategy: :build) }
    end
  end
end
