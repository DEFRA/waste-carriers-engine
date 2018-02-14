FactoryBot.define do
  factory :address do
    trait :has_required_data do
      uprn "340116"
    end

    trait :registered do
      address_type "REGISTERED"
    end
  end
end
