# frozen_string_literal: true

FactoryBot.define do
  factory :payment_summary_form, class: WasteCarriersEngine::PaymentSummaryForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :transient_registration,
            :has_required_data,
            workflow_state: "payment_summary_form",
            temp_payment_method: "card"
          )
        )
      end
    end
  end
end
