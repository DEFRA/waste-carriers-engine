# frozen_string_literal: true

FactoryBot.define do
  factory :edit_registration, class: "WasteCarriersEngine::EditRegistration" do
    initialize_with { new(reg_identifier: create(:registration, :has_required_data, :is_active).reg_identifier) }

    trait :has_finance_details do
      has_changed_registration_type

      finance_details { build(:finance_details, :has_edit_order) }
    end

    trait :has_changed_registration_type do
      registration_type { "carrier_dealer" }
    end
  end
end
