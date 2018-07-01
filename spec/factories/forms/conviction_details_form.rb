FactoryBot.define do
  factory :conviction_details_form, class: WasteCarriersEngine::ConvictionDetailsForm do
    trait :has_required_data do
      first_name "Foo"
      last_name "Bar"
      position "Baz"
      dob_year 2000
      dob_month 1
      dob_day 1
      date_of_birth Date.new(2000, 1, 1)

      initialize_with { new(create(:transient_registration, :has_required_data, :declared_convictions, workflow_state: "conviction_details_form")) }
    end
  end
end
