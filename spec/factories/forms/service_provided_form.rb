FactoryBot.define do
  factory :service_provided_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "service_provided_form")) }
    end
  end
end
