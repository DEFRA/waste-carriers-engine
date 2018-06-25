FactoryBot.define do
  factory :convictionSearchResult do
    trait :match_result_yes do
      match_result "YES"
    end

    trait :match_result_no do
      match_result "NO"
    end

    trait :match_result_unknown do
      match_result "UNKNOWN"
    end
  end
end
