# frozen_string_literal: true

FactoryBot.define do
  factory :contact_address_form, class: WasteCarriersEngine::ContactAddressForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "contact_address_form",
            contact_address: build(:address, :has_required_data, :contact),
            temp_contact_postcode: "FA4 3HT"
          )
        )
      end
    end
  end
end
