# frozen_string_literal: true

FactoryBot.define do
  factory :worldpay_form, class: WasteCarriersEngine::WorldpayForm do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "worldpay_form")) }
    end
  end
end
