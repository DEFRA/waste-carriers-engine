FactoryBot.define do
  factory :keyPerson do
    trait :has_required_data do
      firstName "Kate"
      lastName "Franklin"
      position "Director"
      dateOfBirth Date.new
      personType "Relevant"
    end
  end
end
