FactoryBot.define do
  factory :conviction_details_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "conviction_details_form")) }
    end
  end
end
