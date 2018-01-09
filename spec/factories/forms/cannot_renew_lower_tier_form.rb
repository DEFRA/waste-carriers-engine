FactoryBot.define do
  factory :cannot_renew_lower_tier_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "cannot_renew_lower_tier_form")) }
    end
  end
end
