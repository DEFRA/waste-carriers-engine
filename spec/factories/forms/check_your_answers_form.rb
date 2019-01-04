# frozen_string_literal: true

FactoryBot.define do
  factory :check_your_answers_form, class: WasteCarriersEngine::CheckYourAnswersForm do
    trait :has_required_data do
      initialize_with do
        new(create(:transient_registration,
                   :has_required_data,
                   :has_addresses,
                   :has_key_people,
                   workflow_state: "check_your_answers_form"))
      end
    end

    trait :has_required_overseas_data do
      initialize_with do
        new(create(:transient_registration,
                   :has_required_overseas_data,
                   :has_overseas_addresses,
                   :has_key_people,
                   workflow_state: "check_your_answers_form"))
      end
    end
  end
end
