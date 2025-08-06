# frozen_string_literal: true

FactoryBot.define do
  factory :renewing_registration, class: "WasteCarriersEngine::RenewingRegistration" do
    # Create a new registration when initializing so we can copy its data
    initialize_with { new(reg_identifier: create(:registration, :has_required_data, :expires_soon).reg_identifier) }

    trait :has_required_data do
      location { "england" }
      first_name { "Mary" }
      last_name { "Wollstonecraft" }
      phone_number { "01234 567890" }
      contact_email { "mary@example.com" }
      declared_convictions { "no" }
      temp_cards { 1 }

      has_postcode
    end

    trait :has_addresses do
      addresses do
        [association(:address, :has_required_data, :registered, :from_os_places, strategy: :build),
         association(:address, :has_required_data, :contact, :from_os_places, strategy: :build)]
      end
    end

    trait :has_registered_address do
      addresses do
        [association(:address, :has_required_data, :registered, :from_os_places, strategy: :build)]
      end
    end

    trait :expires_today do
      initialize_with { new(reg_identifier: create(:registration, :has_required_data, :expires_today).reg_identifier) }
    end

    trait :has_key_people do
      key_people do
        [association(:key_person, :has_required_data, :unmatched_conviction_search_result, :main, strategy: :build),
         association(:key_person, :has_required_data, :unmatched_conviction_search_result, :relevant, strategy: :build)]
      end
    end

    trait :has_postcode do
      temp_company_postcode { "BS1 5AH" }
      temp_contact_postcode { "BS1 5AH" }
    end

    trait :declared_convictions do
      declared_convictions { "yes" }
    end

    trait :is_submitted do
      workflow_state { "renewal_received_pending_payment_form" }
    end

    trait :has_finance_details do
      after(:build, :create) do |renewing_registration|
        renewing_registration.prepare_for_payment(:govpay)
      end
    end

    trait :has_pending_govpay_status do
      finance_details { association :finance_details, :has_pending_govpay_order, strategy: :build }
    end

    trait :has_paid_order do
      finance_details { association(:finance_details, :has_paid_order_and_payment, strategy: :build) }
    end

    trait :has_paid_order_with_two_orders do
      finance_details { association(:finance_details, :has_paid_orders_and_payments, strategy: :build) }
    end

    trait :has_conviction_search_result do
      conviction_search_result { association(:conviction_search_result, :match_result_no, strategy: :build) }
    end

    trait :requires_conviction_check do
      is_submitted
      key_people { [association(:key_person, :matched_conviction_search_result, strategy: :build)] }
      conviction_search_result { association(:conviction_search_result, :match_result_yes, strategy: :build) }
      conviction_sign_offs { [association(:conviction_sign_off, strategy: :build)] }
    end

    trait :has_rejected_conviction_sign_off do
      declared_convictions
      conviction_search_result { association(:conviction_sign_off, :rejected, strategy: :build) }
    end

    trait :has_unpaid_balance do
      is_submitted
      finance_details { association(:finance_details, balance: 1000, strategy: :build) }
    end

    trait :has_paid_balance do
      finance_details { association(:finance_details, balance: 0, strategy: :build) }
    end

    trait :has_different_contact_email do
      contact_email { "contact-foo@example.com" }
    end

    # Overseas registrations

    trait :has_required_overseas_data do
      location { "overseas" }
      business_type { "overseas" }
      first_name { "Sojourner" }
      last_name { "Truth" }
      phone_number { "01234 567890" }
      contact_email { "sojourner@example.com" }
      declared_convictions { "no" }
      temp_cards { 1 }

      # Create a new registration when initializing so we can copy its data
      initialize_with { new(reg_identifier: create(:registration, :has_required_overseas_data, :expires_soon).reg_identifier) }
    end

    trait :has_overseas_addresses do
      addresses do
        [association(:address, :has_required_data, :registered, :manual_foreign, strategy: :build),
         association(:address, :has_required_data, :contact, :manual_foreign, strategy: :build)]
      end
    end

    trait :has_matching_convictions do
      company_name { "Test Waste Services" }
      company_no { "12345678" }

      key_people do
        [association(:key_person, :has_matching_conviction, :main, strategy: :build)]
      end
    end

    trait :has_revoked_registration do
      # Create a new registration when initializing so we can copy its data
      initialize_with do
        new(reg_identifier: create(:registration, :has_required_data, :is_revoked).reg_identifier)
      end
    end

    trait :has_expired do
      # Create a new registration when initializing so we can copy its data
      initialize_with { new(reg_identifier: create(:registration, :has_required_data, :expired_one_month_ago).reg_identifier) }
    end

    trait :has_expired_today do
      # Create a new registration when initializing so we can copy its data
      initialize_with { new(reg_identifier: create(:registration, :has_required_data, :expires_today).reg_identifier) }
    end

    trait :is_ready_to_complete do
      has_required_data
      has_paid_order
      is_submitted
    end

    trait :revoked do
      after(:build, :create) do |renewing_registration|
        renewing_registration.metaData.revoke
      end
    end
  end
end
