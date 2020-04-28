# frozen_string_literal: true

module WasteCarriersEngine
  class Registration
    include Mongoid::Document
    include CanCheckRegistrationStatus
    include CanFilterConvictionStatus
    include CanHaveRegistrationAttributes
    include CanUseLock

    store_in collection: "registrations"

    embeds_many :past_registrations, class_name: "WasteCarriersEngine::PastRegistration"
    accepts_nested_attributes_for :past_registrations

    before_save :update_last_modified

    validates :reg_identifier,
              :addresses,
              :metaData,
              presence: true

    validates :reg_identifier,
              uniqueness: true

    validates :tier,
              inclusion: { in: TIERS }

    scope :active, -> { where("metaData.status" => "ACTIVE") }
    scope :expired_at_end_of_today, -> { where(:expires_on.lte => Time.now.in_time_zone("London").end_of_day) }
    scope :upper_tier, -> { where(tier: UPPER_TIER) }
    scope :active_and_expired, -> { where("metaData.status" => { :$in => %w[ACTIVE EXPIRED] }) }

    def self.in_grace_window
      date = Time.now.in_time_zone("London").beginning_of_day - Rails.configuration.grace_window.days + 1.day

      where(:expires_on.gte => date)
    end

    def self.not_assisted_digital
      assisted_digital_email = WasteCarriersEngine.configuration.assisted_digital_email

      where("contactEmail" => { :$nin => [nil, assisted_digital_email] })
    end

    alias pending_manual_conviction_check? conviction_check_required?
    alias pending_payment? unpaid_balance?

    def can_start_renewal?
      renewable_tier? && renewable_status? && renewable_date?
    end

    def expire!
      metaData.status = "EXPIRED"

      save!
    end

    private

    def renewable_tier?
      upper_tier?
    end

    def renewable_status?
      active? || expired?
    end

    def renewable_date?
      check_service = ExpiryCheckService.new(self)
      return true if check_service.in_expiry_grace_window?
      return false if check_service.expired?

      check_service.in_renewal_window?
    end
  end
end
