FactoryBot.define do
  factory :declare_convictions_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "declare_convictions_form")) }
    end
  end
end
