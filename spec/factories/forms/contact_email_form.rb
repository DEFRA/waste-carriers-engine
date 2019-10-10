# frozen_string_literal: true

FactoryBot.define do
  factory :contact_email_form, class: WasteCarriersEngine::ContactEmailForm do
    trait :has_required_data do
      confirmed_email { "foo@example.com" }

      initialize_with do
        new(
          create(
            :transient_registration,
            :has_required_data,
            workflow_state: "contact_email_form",
            contact_email: "foo@example.com"
          )
        )
      end
    end
  end
end
