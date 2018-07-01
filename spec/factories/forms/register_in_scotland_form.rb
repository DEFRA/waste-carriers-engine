FactoryBot.define do
  factory :register_in_scotland_form, class: WasteCarriersEngine::RegisterInScotlandForm do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "register_in_scotland_form")) }
    end
  end
end
