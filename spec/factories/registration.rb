FactoryBot.define do
  factory :registration do
    trait :has_required_data do
      account_email "foo@example.com"
      business_type "limitedCompany"
      company_name "Acme Waste"
      company_no "09360070" # We need to use a valid company number
      contact_email "foo@example.com"
      first_name "Jane"
      last_name "Doe"
      registration_type "carrier_broker_dealer"
      phone_number "03708 506506"
      tier "UPPER"

      metaData { build(:metaData, :has_required_data) }

      addresses do
        [build(:address, :has_required_data, :contact, :from_os_places),
         build(:address, :has_required_data, :registered, :from_os_places)]
      end

      keyPeople do
        [build(:key_person, :has_required_data, :main),
         build(:key_person, :has_required_data, :relevant)]
      end
    end

    trait :has_required_overseas_data do
      account_email "foo@example.com"
      business_type "overseas"
      company_name "Acme Waste"
      contact_email "foo@example.com"
      first_name "Jane"
      last_name "Doe"
      registration_type "carrier_broker_dealer"
      phone_number "03708 506506"
      tier "UPPER"

      metaData { build(:metaData, :has_required_data) }

      addresses do
        [build(:address, :has_required_data, :contact, :manual_foreign),
         build(:address, :has_required_data, :registered, :manual_foreign)]
      end

      keyPeople do
        [build(:key_person, :has_required_data, :main),
         build(:key_person, :has_required_data, :relevant)]
      end
    end

    trait :expires_soon do
      metaData { build(:metaData, :has_required_data, status: :ACTIVE) }
      expires_on 2.months.from_now
    end

    trait :expires_later do
      metaData { build(:metaData, :has_required_data, status: :ACTIVE) }
      expires_on 2.years.from_now
    end

    trait :is_pending do
      metaData { build(:metaData, :has_required_data, status: :PENDING) }
    end

    trait :is_active do
      metaData { build(:metaData, :has_required_data, status: :ACTIVE) }
    end

    trait :is_revoked do
      metaData { build(:metaData, :has_required_data, status: :REVOKED) }
    end

    trait :is_refused do
      metaData { build(:metaData, :has_required_data, status: :REFUSED) }
    end

    trait :is_expired do
      metaData { build(:metaData, :has_required_data, status: :EXPIRED) }
    end
  end
end
