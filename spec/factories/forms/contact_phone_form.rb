# frozen_string_literal: true

FactoryBot.define do
  factory :contact_phone_form, class: "WasteCarriersEngine::ContactPhoneForm" do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            phone_number: "03708 506 506",
            workflow_state: "contact_phone_form"
          )
        )
      end
    end
  end
end
