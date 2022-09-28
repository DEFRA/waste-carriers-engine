# frozen_string_literal: true

FactoryBot.define do
  factory :base_form, class: "WasteCarriersEngine::BaseForm" do
    trait :has_required_data do
      initialize_with { new(create(:renewing_registration, :has_required_data)) }
    end
  end
end
