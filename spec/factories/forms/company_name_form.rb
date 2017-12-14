FactoryBot.define do
  factory :company_name_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "company_name_form")) }
    end
  end
end
