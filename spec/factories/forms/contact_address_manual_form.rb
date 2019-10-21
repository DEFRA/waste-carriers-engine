# frozen_string_literal: true

FactoryBot.define do
  factory :contact_address_manual_form, class: WasteCarriersEngine::ContactAddressManualForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :transient_registration,
            :has_required_data,
            :has_addresses,
            workflow_state: "contact_address_manual_form"
          )
        )
      end
    end
  end
end
