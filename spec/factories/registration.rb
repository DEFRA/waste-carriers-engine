# frozen_string_literal: true

FactoryBot.define do
  factory :registration, class: WasteCarriersEngine::Registration do
    sequence :reg_identifier do |n|
      "CBDU#{n}"
    end

    trait :has_required_data do
      account_email { "foo@example.com" }
      business_type { "limitedCompany" }
      business_name { "Acme Waste" }
      company_no { "09360070" } # We need to use a valid company number
      contact_email { "foo@example.com" }
      first_name { "Jane" }
      last_name { "Doe" }
      registration_type { "carrier_broker_dealer" }
      phone_number { "03708 506506" }
      tier { "UPPER" }

      metaData { build(:metaData, :has_required_data) }

      has_addresses
      has_paid_finance_details

      key_people do
        [build(:key_person, :has_required_data, :main),
         build(:key_person, :has_required_data, :relevant)]
      end
    end

    trait :already_renewed do
      expires_in_3_years

      after :create do |registration|
        past_registration = WasteCarriersEngine::PastRegistration.build_past_registration(registration)
        past_registration.update(expires_on: registration.expires_on - 3.years)
      end
    end

    trait :past_renewal_window do
      expires_on { Time.now.to_date - Helpers::GraceWindows.current_grace_window - 1 }
    end

    trait :lower_tier do
      tier { "LOWER" }
    end

    trait :has_addresses do
      addresses { [build(:address, :has_required_data, :registered, :from_os_places), build(:address, :has_required_data, :contact, :from_os_places)] }
    end

    trait :has_paid_finance_details do
      finance_details { build(:finance_details, :has_paid_order_and_payment) }
    end

    trait :has_copy_cards_order do
      finance_details { build(:finance_details, :has_copy_cards_order) }
    end

    trait :has_required_overseas_data do
      account_email { "foo@example.com" }
      business_type { "overseas" }
      business_name { "Acme Waste" }
      contact_email { "foo@example.com" }
      first_name { "Jane" }
      last_name { "Doe" }
      registration_type { "carrier_broker_dealer" }
      phone_number { "03708 506506" }
      tier { "UPPER" }

      metaData { build(:metaData, :has_required_data) }

      addresses do
        [build(:address, :has_required_data, :contact, :manual_foreign),
         build(:address, :has_required_data, :registered, :manual_foreign)]
      end

      key_people do
        [build(:key_person, :has_required_data, :main),
         build(:key_person, :has_required_data, :relevant)]
      end
    end

    trait :has_mulitiple_key_people do
      key_people do
        [
          build(:key_person, :has_required_data, :main),
          build(:key_person, :has_required_data, :main, first_name: "Ryan", last_name: "Gosling"),
          build(:key_person, :has_required_data, :relevant),
          build(:key_person, :has_required_data, :relevant, first_name: "Corey", last_name: "Stoll")
        ]
      end
    end

    trait :expired_one_month_ago do
      metaData { build(:metaData, :has_required_data, status: :EXPIRED) }
      expires_on { 1.month.ago }
    end

    trait :expires_soon do
      metaData { build(:metaData, :has_required_data, status: :ACTIVE) }
      expires_on { 2.months.from_now }
    end

    trait :expires_today do
      metaData { build(:metaData, :has_required_data, status: :EXPIRED) }
      expires_on { Date.today }
    end

    trait :expires_later do
      metaData { build(:metaData, :has_required_data, status: :ACTIVE) }
      expires_on { 2.years.from_now }
    end

    trait :expires_in_3_years do
      metaData { build(:metaData, :has_required_data, status: :ACTIVE) }
      expires_on { 3.years.from_now }
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

    trait :cancelled do
      metaData { build(:metaData, :cancelled) }
    end
  end
end
