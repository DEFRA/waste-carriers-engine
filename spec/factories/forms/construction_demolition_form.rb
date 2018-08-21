FactoryBot.define do
  factory :construction_demolition_form, class: WasteCarriersEngine::ConstructionDemolitionForm do
    trait :has_required_data do
      construction_waste { "yes" }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "construction_demolition_form")) }
    end
  end
end
