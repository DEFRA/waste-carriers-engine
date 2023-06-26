# frozen_string_literal: true

FactoryBot.define do
  factory :payment_method_confirmation_form, class: "WasteCarriersEngine::PaymentMethodConfirmationForm" do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "payment_method_confirmation_form",
            temp_confirm_payment_method: "no"
          )
        )
      end
    end
  end
end
