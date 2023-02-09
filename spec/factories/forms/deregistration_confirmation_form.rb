# frozen_string_literal: true

FactoryBot.define do
  factory :deregistration_confirmation_form, class: "WasteCarriersEngine::DeregistrationConfirmationForm" do
    initialize_with do
      new(create(:deregistering_registration))
    end
  end
end
