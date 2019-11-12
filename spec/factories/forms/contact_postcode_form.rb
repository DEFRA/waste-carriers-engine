# frozen_string_literal: true

FactoryBot.define do
  factory :contact_postcode_form, class: WasteCarriersEngine::ContactPostcodeForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "contact_postcode_form",
            temp_contact_postcode: "BS1 5AH"
          )
        )
      end
    end
  end
end
