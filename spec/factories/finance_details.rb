FactoryBot.define do
  factory :finance_details do
    trait :has_required_data do
      balance 10_000
    end
  end
end
