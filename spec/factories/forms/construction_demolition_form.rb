FactoryBot.define do
  factory :construction_demolition_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "construction_demolition_form")) }
    end
  end
end
