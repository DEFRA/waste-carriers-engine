FactoryBot.define do
  factory :service_provided_form, class: WasteCarriersEngine::ServiceProvidedForm do
    trait :has_required_data do
      is_main_service "true"

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "service_provided_form")) }
    end
  end
end
