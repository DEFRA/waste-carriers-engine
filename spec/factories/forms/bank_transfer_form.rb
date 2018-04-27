FactoryBot.define do
  factory :bank_transfer_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "bank_transfer_form")) }
    end
  end
end
