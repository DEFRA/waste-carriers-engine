FactoryBot.define do
  factory :contact_name_form, class: WasteCarriersEngine::ContactNameForm do
    trait :has_required_data do
      first_name "Anne"
      last_name "Edwards"

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "contact_name_form")) }
    end
  end
end
