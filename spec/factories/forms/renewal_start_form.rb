# frozen_string_literal: true

FactoryBot.define do
  factory :renewal_start_form, class: "WasteCarriersEngine::RenewalStartForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "renewal_start_form")) }
    end
  end
end
