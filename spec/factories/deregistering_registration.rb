# frozen_string_literal: true

FactoryBot.define do
  factory :deregistering_registration, class: "WasteCarriersEngine::DeregisteringRegistration" do
    initialize_with { new(reg_identifier: create(:registration, :has_required_data).reg_identifier) }

    metaData { association(:metaData, strategy: :build) }

    transient do
      metadata_status { "ACTIVE" }
      tier { "LOWER" }
    end

    after :build do |deregistering_registration, options|
      original_registration = deregistering_registration.registration

      original_registration.metaData.status = options.metadata_status if options.metadata_status.present?
      original_registration.tier = options.tier if options.tier.present?

      original_registration.save!
    end
  end
end
