# frozen_string_literal: true

FactoryBot.define do
  factory :contact_name_form, class: "WasteCarriersEngine::ContactNameForm" do
    trait :has_required_data do
      initialize_with do
        new(
          create(
            :renewing_registration,
            :has_required_data,
            workflow_state: "contact_name_form",
            first_name: "Anne",
            last_name: "Edwards"
          )
        )
      end
    end
  end
end
