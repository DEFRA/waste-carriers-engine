FactoryBot.define do
  factory :contact_email_form, class: WasteCarriersEngine::ContactEmailForm do
    trait :has_required_data do
      contact_email { "foo@example.com" }
      confirmed_email { "foo@example.com" }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "contact_email_form")) }
    end
  end
end
