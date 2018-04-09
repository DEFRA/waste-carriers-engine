FactoryBot.define do
  factory :base_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data)) }
    end
  end
end
