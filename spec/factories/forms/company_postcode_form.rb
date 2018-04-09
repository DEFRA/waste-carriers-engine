FactoryBot.define do
  factory :company_postcode_form do
    trait :has_required_data do
      temp_company_postcode "BS1 5AH"

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "company_postcode_form")) }
    end
  end
end
