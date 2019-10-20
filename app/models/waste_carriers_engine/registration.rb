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

    def can_start_renewal?
      renewable_tier? && renewable_status? && renewable_date?
    end

    private

    def renewable_tier?
      tier == "UPPER"
    end

    def renewable_status?
      %w[ACTIVE EXPIRED].include?(metaData.status)
    end

    def renewable_date?
      check_service = ExpiryCheckService.new(self)
      return true if check_service.in_expiry_grace_window?
      return false if check_service.expired?

      check_service.in_renewal_window?
    end
  end
end
