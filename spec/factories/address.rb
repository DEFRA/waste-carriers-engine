FactoryBot.define do
  factory :address do
    trait :has_required_data do
      address_line_1 "Foo Gardens"
    end

    trait :contact do
      address_type "CONTACT"
    end

    trait :registered do
      address_type "REGISTERED"
    end
  end
end
