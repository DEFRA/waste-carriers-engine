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
    scope :not_cancelled, -> { where("metaData.status" => { :$nin => %w[INACTIVE] }) }

    field :renew_token, type: String

    def self.lower_tier_or_in_grace_window
      date = Time.now.in_time_zone("London").beginning_of_day - Rails.configuration.grace_window.days + 1.day

      any_of({ :expires_on.gte => date }, { tier: LOWER_TIER })
    end

    alias pending_manual_conviction_check? conviction_check_required?
    alias pending_payment? unpaid_balance?

    def can_start_renewal?
      renewable_tier? && renewable_status? && renewable_date?
    end

    def generate_renew_token!
      self.renew_token = SecureTokenService.run

      save!
    end

    def already_renewed?
      period_after_last_window = Rails.configuration.expires_after.years + Rails.configuration.grace_window.days
      registration_window = expires_on - period_after_last_window + 1.day

      past_registrations.where(cause: nil, :expires_on.gte => registration_window).any?
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

    private

    def renewable_tier?
      upper_tier?
    end

    def renewable_status?
      active? || expired?
    end

    def renewable_date?
      return true if check_service.in_expiry_grace_window?
      return false if check_service.expired?

      check_service.in_renewal_window?
    end

    def check_service
      @_check_service ||= ExpiryCheckService.new(self)
    end
  end
end
