# frozen_string_literal: true

FactoryBot.define do
  factory :other_businesses_form, class: WasteCarriersEngine::OtherBusinessesForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :transient_registration,
            :has_required_data,
            workflow_state: "other_businesses_form",
            other_businesses: "yes"
          )
        )
      end
    end
  end
end
