# frozen_string_literal: true

FactoryBot.define do
  factory :register_in_northern_ireland_form, class: "WasteCarriersEngine::RegisterInNorthernIrelandForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "register_in_northern_ireland_form")) }
    end
  end
end
