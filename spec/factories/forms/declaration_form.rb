# frozen_string_literal: true

FactoryBot.define do
  factory :declaration_form, class: WasteCarriersEngine::DeclarationForm do
    trait :has_required_data do
      declaration { 1 }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "declaration_form")) }
    end
  end
end
