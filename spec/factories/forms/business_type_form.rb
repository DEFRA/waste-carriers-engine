FactoryBot.define do
  factory :business_type_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "business_type_form")) }
    end
  end
end
