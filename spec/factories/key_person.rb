FactoryBot.define do
  factory :key_person do
    trait :has_required_data do
      first_name "Kate"
      last_name "Franklin"
      position "Director"
      dob_day 1
      dob_month 1
      dob_year 2000
    end

    trait :main do
      person_type "key"
    end

    trait :relevant do
      person_type "relevant"
    end
  end
end
