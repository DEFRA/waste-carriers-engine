FactoryBot.define do
  factory :tier_check_form, class: WasteCarriersEngine::TierCheckForm do
    trait :has_required_data do
      temp_tier_check false

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "tier_check_form")) }
    end
  end
end
