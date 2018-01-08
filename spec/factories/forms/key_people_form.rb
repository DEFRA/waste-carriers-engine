FactoryBot.define do
  factory :key_people_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "key_people_form")) }
    end
  end
end
