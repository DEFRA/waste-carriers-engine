FactoryBot.define do
  factory :contact_name_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "contact_name_form")) }
    end
  end
end
