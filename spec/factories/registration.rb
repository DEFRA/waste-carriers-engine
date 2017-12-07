FactoryBot.define do
  factory :registration do
    trait :has_required_data do
      reg_identifier "CBDU1"

      metaData { build(:metaData) }
      addresses { [build(:address)] }
    end

    trait :has_expires_on do
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
