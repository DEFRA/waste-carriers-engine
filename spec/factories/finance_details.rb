FactoryBot.define do
  factory :finance_details do
    trait :has_required_data do
      balance 100
    end
  end
end
