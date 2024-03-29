# frozen_string_literal: true

FactoryBot.define do
  factory :registration_number_form, class: "WasteCarriersEngine::RegistrationNumberForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "registration_number_form")) }
    end
  end
end
