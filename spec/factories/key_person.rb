FactoryBot.define do
  factory :key_person, class: WasteCarriersEngine::KeyPerson do
    trait :has_required_data do
      first_name { "Kate" }
      last_name { "Franklin" }
      position { "Director" }
      dob_day { 1 }
      dob_month { 1 }
      dob_year { 2000 }

      # Initialise with attributes so we can set the date of birth
      initialize_with { new(attributes) }
    end

    trait :main do
      person_type { "KEY" }
    end

    trait :relevant do
      person_type { "RELEVANT" }
    end

    trait :has_matching_conviction do
      first_name { "Fred" }
      last_name { "Blogs" }
      position { "Director" }
      dob_day { 1 }
      dob_month { 1 }
      dob_year { 1981 }

      # Initialise with attributes so we can set the date of birth
      initialize_with { new(attributes) }
    end

    trait :matched_conviction_search_result do
      conviction_search_result { build(:conviction_search_result, :match_result_yes) }
    end

    trait :unmatched_conviction_search_result do
      conviction_search_result { build(:conviction_search_result, :match_result_no) }
    end

    trait :unknown_conviction_search_result do
      conviction_search_result { build(:conviction_search_result, :match_result_unknown) }
    end
  end
end
