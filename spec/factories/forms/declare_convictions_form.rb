# frozen_string_literal: true

FactoryBot.define do
  factory :declare_convictions_form, class: WasteCarriersEngine::DeclareConvictionsForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :transient_registration,
            :has_required_data,
            workflow_state: "declare_convictions_form",
            declared_convictions: "no"
          )
        )
      end
    end
  end
end
