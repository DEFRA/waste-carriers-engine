# frozen_string_literal: true

FactoryBot.define do
  factory :company_name_form, class: "WasteCarriersEngine::CompanyNameForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "company_name_form")) }
    end
  end
end
