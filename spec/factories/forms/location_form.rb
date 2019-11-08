# frozen_string_literal: true

FactoryBot.define do
  factory :location_form, class: WasteCarriersEngine::LocationForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "location_form",
            location: "england"
          )
        )
      end
    end
  end
end
