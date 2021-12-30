# frozen_string_literal: true

FactoryBot.define do
  factory :check_company_form, class: WasteCarriersEngine::CheckCompanyForm do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "check_company_form")) }
    end
  end
end
