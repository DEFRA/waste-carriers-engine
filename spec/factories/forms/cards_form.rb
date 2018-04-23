FactoryBot.define do
  factory :worldpay_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "worldpay_form")) }
    end
  end
end
