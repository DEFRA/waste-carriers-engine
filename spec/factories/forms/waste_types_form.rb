# frozen_string_literal: true

FactoryBot.define do
  factory :waste_types_form, class: WasteCarriersEngine::WasteTypesForm do
    trait :has_required_data do
      only_amf { "yes" }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "waste_types_form")) }
    end
  end
end
