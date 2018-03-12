FactoryBot.define do
  factory :location_form do
    trait :has_required_data do
      location "england"

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "location_form")) }
    end
  end
end
