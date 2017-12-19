FactoryBot.define do
  factory :transient_registration do
    trait :has_required_data do
      reg_identifier { create(:registration, :has_required_data, :expires_soon).reg_identifier }
    end
  end
end
