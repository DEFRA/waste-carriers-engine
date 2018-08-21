FactoryBot.define do
  factory :contact_phone_form, class: WasteCarriersEngine::ContactPhoneForm do
    trait :has_required_data do
      phone_number { "03708 506 506" }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "contact_phone_form")) }
    end
  end
end
