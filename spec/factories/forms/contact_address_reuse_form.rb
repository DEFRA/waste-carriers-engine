# frozen_string_literal: true

FactoryBot.define do
  factory :contact_address_reuse_form, class: WasteCarriersEngine::ContactAddressReuseForm do
    initialize_with { new(build(:transient_registration)) }
  end
end
