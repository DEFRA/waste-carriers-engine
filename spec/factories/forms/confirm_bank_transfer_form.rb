# frozen_string_literal: true

FactoryBot.define do
  factory :confirm_bank_transfer_form, class: "WasteCarriersEngine::ConfirmBankTransferForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "confirm_bank_transfer_form")) }
    end
  end
end
