FactoryBot.define do
  factory :payment_summary_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "payment_summary_form")) }
    end
  end
end
