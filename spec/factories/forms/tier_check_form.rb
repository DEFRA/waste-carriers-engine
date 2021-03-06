# frozen_string_literal: true

FactoryBot.define do
  factory :tier_check_form, class: WasteCarriersEngine::TierCheckForm do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "tier_check_form",
            temp_tier_check: "no"
          )
        )
      end
    end
  end
end
