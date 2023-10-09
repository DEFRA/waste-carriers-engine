# frozen_string_literal: true

FactoryBot.define do
  factory :registration, class: "WasteCarriersEngine::Registration" do
    sequence :reg_identifier do |n|
      "CBDU#{n}"
    end

    trait :has_required_data do
      account_email { "foo@example.com" }
      business_type { "limitedCompany" }
      company_name { "Acme Waste" }
      company_no { "09360070" } # We need to use a valid company number
      contact_email { "foo@example.com" }
      first_name { "Jane" }
      last_name { "Doe" }
      registration_type { "carrier_broker_dealer" }
      phone_number { "03708 506506" }
      tier { "UPPER" }

      metaData { association :metaData, :has_required_data, strategy: :build }
      has_addresses
      has_paid_finance_details

      key_people do
        [
          association(:key_person, :has_required_data, :main, strategy: :build),
          association(:key_person, :has_required_data, :relevant, strategy: :build)
        ]
      end
    end

    trait :has_addresses do
      addresses do
        [
          association(:address, :has_required_data, :registered, :from_os_places, strategy: :build),
          association(:address, :has_required_data, :contact, :from_os_places, strategy: :build)
        ]
      end
    end

    trait :has_paid_finance_details do
      finance_details { association :finance_details, :has_paid_order_and_payment, strategy: :build }
    end

    trait :has_copy_cards_order do
      finance_details { association :finance_details, :has_copy_cards_order, strategy: :build }
    end

    trait :already_renewed do
      expires_in_3_years

      after :create do |registration|
        past_registration = WasteCarriersEngine::PastRegistration.build_past_registration(registration)
        past_registration.update(expires_on: registration.expires_on - 3.years)
      end
    end

    trait :past_renewal_window do
      expires_on { Time.now.to_date - Rails.configuration.grace_window - 1 }
    end

    trait :lower_tier do
      tier { "LOWER" }
    end

    trait :has_required_overseas_data do
      account_email { "foo@example.com" }
      business_type { "overseas" }
      company_name { "Acme Waste" }
      contact_email { "foo@example.com" }
      first_name { "Jane" }
      last_name { "Doe" }
      registration_type { "carrier_broker_dealer" }
      phone_number { "03708 506506" }
      tier { "UPPER" }

      metaData { association :metaData, :has_required_data, strategy: :build }

      addresses do
        [
          association(:address, :has_required_data, :contact, :manual_foreign, strategy: :build),
          association(:address, :has_required_data, :registered, :manual_foreign, strategy: :build)
        ]
      end

      key_people do
        [
          association(:key_person, :has_required_data, :main, strategy: :build),
          association(:key_person, :has_required_data, :relevant, strategy: :build)
        ]
      end
    end

    trait :has_mulitiple_key_people do
      key_people do
        [
          association(:key_person, :has_required_data, :main, strategy: :build),
          association(:key_person, :has_required_data, :main, first_name: "Ryan", last_name: "Gosling", strategy: :build),
          association(:key_person, :has_required_data, :relevant, strategy: :build),
          association(:key_person, :has_required_data, :relevant, first_name: "Corey", last_name: "Stoll", strategy: :build)
        ]
      end
    end

    trait :expired_one_month_ago do
      metaData { association :metaData, :has_required_data, status: :EXPIRED, strategy: :build }
      expires_on { 1.month.ago }
    end

    trait :expires_soon do
      metaData { association :metaData, :has_required_data, status: :ACTIVE, strategy: :build }
      expires_on { 2.months.from_now }
    end

    trait :expires_today do
      metaData { association :metaData, :has_required_data, status: :EXPIRED, strategy: :build }
      expires_on { Date.today }
    end

    trait :expires_later do
      metaData { association :metaData, :has_required_data, status: :ACTIVE, strategy: :build }
      expires_on { 2.years.from_now }
    end

    trait :expires_in_3_years do
      metaData { association :metaData, :has_required_data, status: :ACTIVE, strategy: :build }
      expires_on { 3.years.from_now }
    end

    trait :is_pending do
      metaData { association :metaData, :has_required_data, status: :PENDING, strategy: :build }
    end

    trait :is_active do
      metaData { association :metaData, :has_required_data, status: :ACTIVE, strategy: :build }
    end

    trait :is_inactive do
      metaData { association :metaData, :has_required_data, status: :INACTIVE, strategy: :build }
    end

    trait :is_revoked do
      metaData { association :metaData, :has_required_data, status: :REVOKED, strategy: :build }
    end

    trait :is_refused do
      metaData { association :metaData, :has_required_data, status: :REFUSED, strategy: :build }
    end

    trait :is_expired do
      metaData { association :metaData, :has_required_data, status: :EXPIRED, strategy: :build }
    end

    trait :cancelled do
      metaData { association :metaData, :cancelled, strategy: :build }
    end
  end
end
