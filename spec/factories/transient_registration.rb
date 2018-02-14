FactoryBot.define do
  factory :transient_registration do
    trait :has_required_data do
      # Create a new registration when initializing so we can copy its data
      initialize_with { new(reg_identifier: create(:registration, :has_required_data, :expires_soon).reg_identifier) }
    end

    trait :has_addresses do
      addresses { [build(:address, :has_required_data, :registered), build(:address, :has_required_data, :contact)] }
    end
  end
end
