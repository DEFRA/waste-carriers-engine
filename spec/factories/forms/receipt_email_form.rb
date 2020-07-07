# frozen_string_literal: true

FactoryBot.define do
  factory :receipt_email_form, class: WasteCarriersEngine::ReceiptEmailForm do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "receipt_email_form")) }
    end
  end
end
