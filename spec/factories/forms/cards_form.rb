# frozen_string_literal: true

FactoryBot.define do
  factory :cards_form, class: "WasteCarriersEngine::CardsForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data, workflow_state: "cards_form", temp_cards: 1)) }
    end
  end
end
