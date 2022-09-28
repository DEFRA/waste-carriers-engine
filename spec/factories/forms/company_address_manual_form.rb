# frozen_string_literal: true

FactoryBot.define do
  factory :company_address_manual_form, class: "WasteCarriersEngine::CompanyAddressManualForm" do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            :has_addresses,
            workflow_state: "company_address_manual_form"
          )
        )
      end
    end
  end
end
