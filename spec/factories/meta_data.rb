# frozen_string_literal: true

FactoryBot.define do
  factory :metaData, class: "WasteCarriersEngine::MetaData" do
    trait :has_required_data do
      date_registered { Time.current }
      date_activated { Time.current }
      certificate_version { 1 }
      certificate_version_history { [{ foo: :bar }] }
    end

    trait :cancelled do
      has_required_data
      status { "INACTIVE" }
    end
  end
end
