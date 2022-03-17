# frozen_string_literal: true

FactoryBot.define do
  factory :incorrect_company_form, class: WasteCarriersEngine::IncorrectCompanyForm do
    trait :has_required_data do
      initialize_with { new(create(:new_registration, :has_required_data, workflow_state: "incorrect_company_form")) }
    end
  end
end
