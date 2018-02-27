FactoryBot.define do
  factory :key_people_form do
    trait :has_required_data do
      first_name "Foo"
      last_name "Bar"
      dob_year 2000
      dob_month 1
      dob_day 1

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "key_people_form")) }
    end
  end
end
