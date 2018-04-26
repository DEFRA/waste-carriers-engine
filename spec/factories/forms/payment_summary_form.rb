FactoryBot.define do
  factory :payment_summary_form do
    trait :has_required_data do
      temp_payment_method "card"

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "payment_summary_form")) }
    end
  end
end
