FactoryBot.define do
  factory :registration do
    trait :has_required_data do
      business_type "limitedCompany"
      registration_type "carrier_broker_dealer"
      company_no "12345678"

      metaData { build(:metaData) }
      addresses { [build(:address)] }
      tier "UPPER"
    end

    trait :expires_soon do
      expires_on 2.months.from_now
    end

    trait :expires_later do
      expires_on 2.years.from_now
    end

    trait :is_pending do
      metaData { build(:metaData, status: :pending) }
    end

    trait :is_active do
      metaData { build(:metaData, status: :active) }
    end

    trait :is_revoked do
      metaData { build(:metaData, status: :revoked) }
    end

    trait :is_refused do
      metaData { build(:metaData, status: :refused) }
    end

    trait :is_expired do
      metaData { build(:metaData, status: :expired) }
    end
  end
end
