# frozen_string_literal: true

module WasteCarriersEngine
  class Registration
    include Mongoid::Document
    include CanCheckRegistrationStatus
    include CanHaveRegistrationAttributes
    include CanGenerateRegIdentifier

    store_in collection: "registrations"

    embeds_many :past_registrations, class_name: "WasteCarriersEngine::PastRegistration"
    accepts_nested_attributes_for :past_registrations

    before_validation :generate_reg_identifier, on: :create
    before_save :update_last_modified

    validates :reg_identifier,
              :addresses,
              :metaData,
              presence: true

    validates :reg_identifier,
              uniqueness: true

    validates :tier,
              inclusion: { in: %w[UPPER LOWER] }
  end
end
