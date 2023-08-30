# frozen_string_literal: true

FactoryBot.define do
  factory :renewal_stop_form, class: "WasteCarriersEngine::RenewalStopForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "renewal_stop_form")) }
    end
  end
end
