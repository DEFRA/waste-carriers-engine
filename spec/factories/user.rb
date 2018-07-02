FactoryBot.define do
  factory :user, class: WasteCarriersEngine::User do
    sequence :email do |n|
      "user#{n}@example.com"
    end

    password "Secret123"
  end
end
