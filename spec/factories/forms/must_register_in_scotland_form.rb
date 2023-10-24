# frozen_string_literal: true

FactoryBot.define do
  factory :must_register_in_scotland_form, class: "WasteCarriersEngine::MustRegisterInScotlandForm" do
    trait :has_required_data do
      initialize_with { new(create(:new_registration, :has_required_data, workflow_state: "must_register_in_scotland_form")) }
    end
  end
end
