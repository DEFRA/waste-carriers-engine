FactoryBot.define do
  factory :contact_postcode_form, class: WasteCarriersEngine::ContactPostcodeForm do
    trait :has_required_data do
      temp_contact_postcode "BS1 5AH"

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "contact_postcode_form")) }
    end
  end
end
