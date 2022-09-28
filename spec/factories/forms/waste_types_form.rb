# frozen_string_literal: true

FactoryBot.define do
  factory :waste_types_form, class: "WasteCarriersEngine::WasteTypesForm" do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "waste_types_form",
            only_amf: "yes"
          )
        )
      end
    end
  end
end
