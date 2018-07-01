FactoryBot.define do
  factory :renewal_received_form, class: WasteCarriersEngine::RenewalReceivedForm do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "renewal_received_form")) }
    end
  end
end
