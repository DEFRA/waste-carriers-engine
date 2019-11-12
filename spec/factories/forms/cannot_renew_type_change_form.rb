# frozen_string_literal: true

FactoryBot.define do
  factory :cannot_renew_type_change_form, class: WasteCarriersEngine::CannotRenewTypeChangeForm do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "cannot_renew_type_change_form")) }
    end
  end
end
