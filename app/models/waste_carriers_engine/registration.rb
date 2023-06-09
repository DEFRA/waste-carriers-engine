# frozen_string_literal: true

module WasteCarriersEngine
  class Registration
    include Mongoid::Document
    include CanCheckRegistrationStatus
    include CanFilterConvictionStatus
    include CanHaveDeregistrationToken
    include CanHaveRegistrationAttributes
    include CanPresentEntityDisplayName
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
    scope :lower_tier, -> { where(tier: LOWER_TIER) }
    scope :active_and_expired, -> { where("metaData.status" => { :$in => %w[ACTIVE EXPIRED] }) }
    scope :not_cancelled, -> { where("metaData.status" => { :$nin => %w[INACTIVE] }) }

    field :renew_token, type: String

    def self.lower_tier_or_unexpired
      beginning_of_today = Time.now.in_time_zone("London").beginning_of_day
      expiry_date = beginning_of_today + 1.day

      any_of(
        # Registration is lower tier
        { tier: LOWER_TIER },
        # Registration expires on or after the current date
        { :expires_on.gte => expiry_date }
      )
    end

    alias pending_manual_conviction_check? conviction_check_required?
    alias pending_payment? unpaid_balance?

    def renew_token
      if self[:renew_token].nil? && can_start_renewal?
        self[:renew_token] = SecureTokenService.run
        save!
      end

      self[:renew_token]
    end

    def can_start_renewal?
      renewable_tier? && renewable_status? && renewable_date?
    end

    def already_renewed?
      # Does a past registration exist which was created by a renewal and has
      # an expiry date less than 6 months old? If so, we can determine that
      # a renewal has recently been created for a registration that would
      # otherwise be expiring around now.
      expires_on_gte = Date.current - Rails.configuration.renewal_window.months

      past_registrations.where(
        cause: nil,
        expires_on: {
          "$gte" => expires_on_gte
        }
      ).any?
    end

    def past_renewal_window?
      check_service.expired? && !check_service.in_expiry_grace_window?
    end

    def expire!
      metaData.status = "EXPIRED"

      save!
    end

    def renewal
      RenewingRegistration.where(reg_identifier: reg_identifier).first
    end

    def original_registration_date
      if past_registrations.any?
        past_registrations.first.metaData&.dateRegistered
      else
        metaData&.dateRegistered
      end
    end

    private

    def renewable_tier?
      upper_tier?
    end

    def renewable_status?
      active? || expired?
    end

    def renewable_date?
      return false if expires_on.blank?
      return true if check_service.in_expiry_grace_window?
      return false if check_service.expired?

      check_service.in_renewal_window?
    end

    def check_service
      @_check_service ||= ExpiryCheckService.new(self)
    end
  end
end
