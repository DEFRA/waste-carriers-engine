# frozen_string_literal: true

FactoryBot.define do
  factory :main_people_form, class: WasteCarriersEngine::MainPeopleForm do
    trait :has_required_data do
      first_name { "Foo" }
      last_name { "Bar" }
      dob_year { 2000 }
      dob_month { 1 }
      dob_day { 1 }
      dob { Date.new(2000, 1, 1) }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "main_people_form")) }
    end
  end
end
