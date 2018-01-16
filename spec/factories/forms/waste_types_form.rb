FactoryBot.define do
  factory :waste_types_form do
    trait :has_required_data do
      only_amf false

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "waste_types_form")) }
    end
  end
end
