# frozen_string_literal: true

FactoryBot.define do
  factory :conviction_sign_off, class: WasteCarriersEngine::ConvictionSignOff do
    confirmed { "no" }

    trait :possible_match do
      workflow_state { "possible_match" }
    end

    trait :checks_in_progress do
      workflow_state { "checks_in_progress" }
    end

    trait :approved do
      workflow_state { "approved" }
    end

    trait :rejected do
      workflow_state { "rejected" }
    end
  end
end
