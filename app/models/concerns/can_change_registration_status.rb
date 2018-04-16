module CanChangeRegistrationStatus
  extend ActiveSupport::Concern
  include Mongoid::Document
  include CanCalculateRenewalDates

  included do
    include AASM

    field :status, type: String

    aasm column: :status do
      # States
      state :pending, initial: true
      state :active
      state :revoked
      state :refused
      state :expired

      # Transitions
      after_all_transitions :log_status_change

      # TODO: Confirm what this workflow actually is
      event :activate do
        transitions from: :pending,
                    to: :active,
                    after: :set_expiry_date
      end

      event :revoke do
        transitions from: :active,
                    to: :revoked
      end

      event :refuse do
        transitions from: :pending,
                    to: :refused
      end

      event :expire do
        transitions from: :active,
                    to: :expired
      end

      event :renew do
        transitions from: :active,
                    to: :active,
                    guard: %i[close_to_expiry_date?
                              should_not_be_expired?],
                    after: :extend_expiry_date
      end
    end

    # Guards
    def close_to_expiry_date?
      expiry_day = registration.expires_on.to_date
      expiry_day < Rails.configuration.renewal_window.months.from_now
    end

    def should_not_be_expired?
      expiry_day = registration.expires_on.to_date
      Date.current < expiry_day
    end

    # Transition effects
    def set_expiry_date
      registration.set(expires_on: Rails.configuration.expires_after.years.from_now)
    end

    def extend_expiry_date
      new_expiry_date = expiry_date_after_renewal(registration.expires_on)
      registration.set(expires_on: new_expiry_date)
    end

    def log_status_change
      logger.debug "Changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
    end
  end
end
