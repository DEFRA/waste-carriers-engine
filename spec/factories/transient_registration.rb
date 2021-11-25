# frozen_string_literal: true

FactoryBot.define do
  factory :transient_registration, class: WasteCarriersEngine::TransientRegistration do
    trait :has_required_data do
      location { "england" }
      declared_convictions { "no" }
      temp_cards { 1 }

      has_postcode
    end

    trait :has_addresses do
      addresses { [build(:address, :has_required_data, :registered, :from_os_places), build(:address, :has_required_data, :contact, :from_os_places)] }
    end

    trait :has_registered_address do
      addresses { [build(:address, :has_required_data, :registered, :from_os_places)] }
    end

    trait :has_postcode do
      temp_company_postcode { "BS1 5AH" }
      temp_contact_postcode { "BS1 5AH" }
    end

    trait :requires_conviction_check do
      key_people { [build(:key_person, :matched_conviction_search_result)] }
      conviction_search_result { build(:conviction_search_result, :match_result_yes) }
      conviction_sign_offs { [build(:conviction_sign_off)] }
    end

    trait :has_unpaid_balance do
      finance_details { build(:finance_details, balance: 1000) }
    end

    trait :has_paid_balance do
      finance_details { build(:finance_details, balance: 0) }
    end
  end
end
