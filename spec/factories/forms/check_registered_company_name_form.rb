# frozen_string_literal: true

FactoryBot.define do
  factory :check_registered_company_name_form, class: "WasteCarriersEngine::CheckRegisteredCompanyNameForm" do

    # set a default type
    transient do
      registration_type { :new_registration }
    end

    trait :new_registration do
      registration_type { :new_registration }
    end

    trait :renewing_registration do
      registration_type { :renewing_registration }
    end

    trait :has_required_data do
      initialize_with { new(create(registration_type, :has_required_data, workflow_state: "check_registered_company_name_form")) }
    end
  end
end
