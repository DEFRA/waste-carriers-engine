FactoryBot.define do
  factory :check_your_answers_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration,
                                   :has_required_data,
                                   :has_addresses,
                                   :has_key_people,
                                   workflow_state: "check_your_answers_form")) }
    end

    trait :has_required_overseas_data do
      initialize_with { new(create(:transient_registration,
                                   :has_required_overseas_data,
                                   :has_overseas_addresses,
                                   :has_key_people,
                                   workflow_state: "check_your_answers_form")) }
    end
  end
end
