FactoryBot.define do
  factory :transient_registration, class: WasteCarriersEngine::TransientRegistration do
    trait :has_required_data do
      location { "england" }
      declared_convictions { "no" }
      temp_cards { 1 }

      # Create a new registration when initializing so we can copy its data
      initialize_with { new(reg_identifier: create(:registration, :has_required_data, :expires_soon).reg_identifier) }
    end

    trait :has_addresses do
      addresses { [build(:address, :has_required_data, :registered, :from_os_places), build(:address, :has_required_data, :contact, :from_os_places)] }
    end

    trait :has_key_people do
      key_people do
        [build(:key_person, :has_required_data, :unmatched_conviction_search_result, :main),
         build(:key_person, :has_required_data, :unmatched_conviction_search_result, :relevant)]
      end
    end

    trait :has_postcode do
      temp_company_postcode { "BS1 5AH" }
      temp_contact_postcode { "BS1 5AH" }
    end

    trait :declared_convictions do
      declared_convictions { "yes" }
    end

    trait :has_finance_details do
      after(:build, :create) do |transient_registration|
        WasteCarriersEngine::FinanceDetails.new_finance_details(transient_registration, :worldpay, build(:user))
      end
    end

    trait :has_conviction_search_result do
      conviction_search_result { build(:conviction_search_result, :match_result_no) }
    end

    trait :requires_conviction_check do
      workflow_state { "renewal_received_form" }
      key_people { [build(:key_person, :matched_conviction_search_result)] }
      conviction_search_result { build(:conviction_search_result, :match_result_yes) }
      conviction_sign_offs { [build(:conviction_sign_off)] }
    end

    trait :has_unpaid_balance do
      finance_details { build(:finance_details, balance: 1000) }
    end

    trait :has_paid_balance do
      finance_details { build(:finance_details, balance: 0) }
    end

    trait :has_different_contact_email do
      contact_email { "contact-foo@example.com" }
    end

    # Overseas registrations

    trait :has_required_overseas_data do
      location { "overseas" }
      declared_convictions { "no" }
      temp_cards { 1 }

      # Create a new registration when initializing so we can copy its data
      initialize_with { new(reg_identifier: create(:registration, :has_required_overseas_data, :expires_soon).reg_identifier) }
    end

    trait :has_overseas_addresses do
      addresses do
        [build(:address, :has_required_data, :registered, :manual_foreign),
         build(:address, :has_required_data, :contact, :manual_foreign)]
      end
    end

    trait :has_matching_convictions do
      company_name { "Test Waste Services" }
      company_no { "12345678" }

      key_people do
        [build(:key_person, :has_matching_conviction, :main)]
      end
    end
  end
end
