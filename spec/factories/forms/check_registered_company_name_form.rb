# frozen_string_literal: true

FactoryBot.define do
  factory :check_registered_company_name_form, class: WasteCarriersEngine::CheckRegisteredCompanyNameForm do
    trait :has_required_data do
      initialize_with { new(create(:new_registration, :has_required_data, workflow_state: "check_registered_company_name_form")) }
    end
  end
end
