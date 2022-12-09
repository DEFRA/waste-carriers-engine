# frozen_string_literal: true

FactoryBot.define do
  factory :invalid_company_status_form, class: "WasteCarriersEngine::InvalidCompanyStatusForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "invalid_company_status_form")) }
    end
  end
end
