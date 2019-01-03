# frozen_string_literal: true

FactoryBot.define do
  factory :cards_form, class: WasteCarriersEngine::CardsForm do
    trait :has_required_data do
      temp_cards { 1 }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "cards_form")) }
    end
  end
end
