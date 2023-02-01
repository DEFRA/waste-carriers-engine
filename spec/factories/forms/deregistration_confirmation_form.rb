# frozen_string_literal: true

FactoryBot.define do
  factory :deregistration_confirmation_form, class: "WasteCarriersEngine::DeregistrationConfirmationForm" do
    trait :has_required_data do
      initialize_with { new(create(:registration)) }
    end
  end
end
