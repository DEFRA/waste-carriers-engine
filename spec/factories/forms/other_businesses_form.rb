FactoryBot.define do
  factory :other_businesses_form do
    trait :has_required_data do
      other_businesses "true"

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "other_businesses_form")) }
    end
  end
end
