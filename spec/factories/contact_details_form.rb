FactoryBot.define do
  factory :contactDetailsForm do
    trait :has_required_data do
      firstName "Jane"
      lastName "Hopper"
      phoneNumber "09876 543210"
      contactEmail "test@example.com"

      initialize_with { new(create(:registration, :has_required_data)) }
    end
  end
end
