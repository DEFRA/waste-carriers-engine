# frozen_string_literal: true

FactoryBot.define do
  factory :company_postcode_form, class: "WasteCarriersEngine::CompanyPostcodeForm" do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "company_postcode_form",
            temp_company_postcode: "BS1 5AH"
          )
        )
      end
    end
  end
end
