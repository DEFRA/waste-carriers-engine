# frozen_string_literal: true

FactoryBot.define do
  factory :business_type_form, class: "WasteCarriersEngine::BusinessTypeForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "business_type_form")) }
    end
  end
end
