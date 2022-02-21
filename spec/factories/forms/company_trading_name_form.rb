# frozen_string_literal: true

FactoryBot.define do
  factory :company_trading_name_form, class: WasteCarriersEngine::CompanyTradingNameForm do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "company_trading_name_form")) }
    end
  end
end
