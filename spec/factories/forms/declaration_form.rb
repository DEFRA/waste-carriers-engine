# frozen_string_literal: true

FactoryBot.define do
  factory :declaration_form, class: WasteCarriersEngine::DeclarationForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "declaration_form",
            declaration: 1
          )
        )
      end
    end
  end
end
