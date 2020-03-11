# frozen_string_literal: true

FactoryBot.define do
  factory :counter, class: WasteCarriersEngine::Counter do
    seq { 1 }
    _id { "regid" }
  end
end
