FactoryBot.define do
  factory :tier_check_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "tier_check_form")) }
    end
  end
end
