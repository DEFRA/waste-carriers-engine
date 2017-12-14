FactoryBot.define do
  factory :transient_registration do
    trait :has_required_data do
      # Create a registration and use the reg_identifier so validations pass
      after(:build) do |transient_registration|
        registration = create(:registration, :has_required_data)
        transient_registration.reg_identifier = registration.reg_identifier
      end
    end
  end
end
