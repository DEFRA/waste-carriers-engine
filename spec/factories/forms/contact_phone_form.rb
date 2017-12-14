FactoryBot.define do
  factory :contact_phone_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "contact_phone_form")) }
    end
  end
end
