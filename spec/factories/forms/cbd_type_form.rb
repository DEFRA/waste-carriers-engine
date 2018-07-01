FactoryBot.define do
  factory :cbd_type_form, class: WasteCarriersEngine::CbdTypeForm do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "cbd_type_form")) }
    end
  end
end
