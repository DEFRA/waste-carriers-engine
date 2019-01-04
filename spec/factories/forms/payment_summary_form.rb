# frozen_string_literal: true

FactoryBot.define do
  factory :payment_summary_form, class: WasteCarriersEngine::PaymentSummaryForm do
    trait :has_required_data do
      temp_payment_method { "card" }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "payment_summary_form")) }
    end
  end
end
