FactoryBot.define do
  factory :registration_number_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "registration_number_form")) }
    end
  end
end
