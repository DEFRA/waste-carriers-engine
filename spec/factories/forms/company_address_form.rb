FactoryBot.define do
  factory :company_address_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "company_address_form")) }
    end
  end
end
