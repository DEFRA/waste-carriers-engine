FactoryBot.define do
  factory :contact_details_form do
    trait :has_required_data do
      first_name "Jane"
      last_name "Hopper"
      phone_number "09876 543210"
      contact_email "test@example.com"

      initialize_with { new(create(:registration, :has_required_data)) }
    end
  end
end
