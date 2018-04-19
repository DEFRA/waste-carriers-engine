FactoryBot.define do
  factory :metaData do
    trait :has_required_data do
      date_registered Time.current
    end
  end
end
