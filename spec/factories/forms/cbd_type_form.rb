# frozen_string_literal: true

FactoryBot.define do
  factory :cbd_type_form, class: WasteCarriersEngine::CbdTypeForm do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "cbd_type_form")) }
    end
  end
end
