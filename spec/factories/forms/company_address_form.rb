# frozen_string_literal: true

FactoryBot.define do
  factory :company_address_form, class: "WasteCarriersEngine::CompanyAddressForm" do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "company_address_form",
            registered_address: build(:address, :has_required_data, :registered),
            temp_company_postcode: "FA4 3HT"
          )
        )
      end
    end
  end
end
