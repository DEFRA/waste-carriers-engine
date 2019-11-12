# frozen_string_literal: true

FactoryBot.define do
  factory :renewal_complete_form, class: WasteCarriersEngine::RenewalCompleteForm do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "renewal_complete_form")) }
    end
  end
end
