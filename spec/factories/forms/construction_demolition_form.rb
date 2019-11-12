# frozen_string_literal: true

FactoryBot.define do
  factory :construction_demolition_form, class: WasteCarriersEngine::ConstructionDemolitionForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "construction_demolition_form",
            construction_waste: "yes"
          )
        )
      end
    end
  end
end
