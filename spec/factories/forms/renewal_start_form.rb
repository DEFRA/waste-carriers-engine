FactoryBot.define do
  factory :renewal_start_form do
    trait :has_required_data do
      reg_identifier "CBDU1"

      initialize_with { new(build(:transient_registration, :has_required_data)) }
    end
  end
end
