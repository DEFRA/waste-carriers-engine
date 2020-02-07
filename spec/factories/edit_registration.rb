# frozen_string_literal: true

FactoryBot.define do
  factory :edit_registration, class: WasteCarriersEngine::EditRegistration do
    initialize_with { new(reg_identifier: create(:registration, :has_required_data, :is_active).reg_identifier) }
  end
end
