# frozen_string_literal: true

FactoryBot.define do
  factory :start_form, class: "WasteCarriersEngine::StartForm" do
    initialize_with { new(build(:new_registration)) }
  end
end
