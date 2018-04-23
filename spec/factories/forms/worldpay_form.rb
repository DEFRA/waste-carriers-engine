FactoryBot.define do
  factory :cards_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "cards_form")) }
    end
  end
end
