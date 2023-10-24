# frozen_string_literal: true

FactoryBot.define do
  factory :must_register_in_northern_ireland_form, class: "WasteCarriersEngine::MustRegisterInNorthernIrelandForm" do
    trait :has_required_data do
      initialize_with { new(create(:new_registration, :has_required_data, workflow_state: "must_register_in_northern_ireland_form")) }
    end
  end
end
