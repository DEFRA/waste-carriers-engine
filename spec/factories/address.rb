FactoryBot.define do
  factory :address do
    trait :has_required_data do
      house_number "42"
      address_line_1 "Foo Gardens"
      town_city "Baz City"
      postcode "FA1 1KE"
      uprn "340116"
    end

    trait :contact do
      address_type "CONTACT"
    end

    trait :registered do
      address_type "REGISTERED"
    end

    trait :from_os_places do
      address_mode "address-results"
    end

    trait :manual_uk do
      address_mode "manual-uk"
    end

    trait :manual_foreign do
      address_mode "manual-foreign"
      country "Slovakia"
    end
  end
end
