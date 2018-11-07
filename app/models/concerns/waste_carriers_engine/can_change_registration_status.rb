# frozen_string_literal: true

module WasteCarriersEngine
  module CanChangeRegistrationStatus
    extend ActiveSupport::Concern
    include Mongoid::Document
    include CanCalculateRenewalDates

    included do
      include AASM

      field :status, type: String

      aasm column: :status do
        # States must be capitalised to match what waste-carriers-service adds to the database
        state :PENDING, initial: true
        state :ACTIVE
        state :REVOKED
        state :REFUSED
        state :EXPIRED

        # Transitions
        after_all_transitions :log_status_change

        event :activate do
          transitions from: :PENDING,
                      to: :ACTIVE,
                      after: :set_expiry_date
        end

        event :revoke do
          transitions from: :ACTIVE,
                      to: :REVOKED
        end

        event :refuse do
          transitions from: :PENDING,
                      to: :REFUSED
        end

        event :expire do
          transitions from: :ACTIVE,
                      to: :EXPIRED
        end

        event :renew do
          transitions from: %i[ACTIVE
                               EXPIRED],
                      to: :ACTIVE,
                      guard: %i[renewal_allowed?],
                      after: %i[extend_expiry_date
                                update_activation_timestamps]
        end
      end

      # Transition effects
      def set_expiry_date
        registration.expires_on = Rails.configuration.expires_after.years.from_now
      end

      def extend_expiry_date
        new_expiry_date = expiry_date_after_renewal(registration.expires_on)
        registration.expires_on = new_expiry_date
      end

      def update_activation_timestamps
        self.date_registered = DateTime.current
        self.date_activated = date_registered
      end

      def log_status_change
        logger.debug "Changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
      end
    end

    private

    # Guards
    def renewal_allowed?
      return true if renewal_application_submitted?
      return true if in_expiry_grace_window?

      # The only time an expired registration can be renewed is if the application has previously been submitted,
      # or it is withion the grace window - otherwise expiry is an automatic no
      return false if EXPIRED?

      close_to_expiry_date? && should_not_be_expired?
    end

    def renewal_application_submitted?
      transient_registration = TransientRegistration.where(reg_identifier: registration.reg_identifier).first
      return false unless transient_registration.present?

      transient_registration.workflow_state == "renewal_received_form"
    end

    def close_to_expiry_date?
      expiry_day = expiry_time_adjusted_for_daylight_savings.to_date
      expiry_day < Rails.configuration.renewal_window.months.from_now
    end

    def should_not_be_expired?
      expiry_day = expiry_time_adjusted_for_daylight_savings.to_date
      # We store dates and times in UTC, but want to use the current date in the UK, not necessarily UTC
      current_day = Time.now.in_time_zone("London").to_date

      current_day < expiry_day
    end

    # Its important to note that a registration is expired on its expires_on date.
    # For example if the expires_on date is Oct 1, then the registration was
    # ACTIVE Sept 30, and EXPIRED Oct 1. If the grace window is 3 days, just
    # adding 3 days to that date would give the impression the grace window lasts
    # till Oct 4 (i.e. 1 + 3) when in fact we need to include the 1st as one of
    # our grace window days.
    def in_expiry_grace_window?
      expiry_day = expiry_time_adjusted_for_daylight_savings.to_date
      # We store dates and times in UTC, but want to use the current date in the UK, not necessarily UTC
      current_day = Time.now.in_time_zone("London").to_date
      last_day_of_grace_window = (expiry_day + Rails.configuration.grace_window) - 1.day

      current_day >= expiry_day && current_day <= last_day_of_grace_window
    end

    # expires_on is stored as a Time in UTC and then converted to a Date.
    # If a user first registered near midnight around the transition between GMT and BST (or the other way round),
    # there is a risk that the UTC date will not be the same as the UK date.
    # So we should check for this and compensate to avoid expiring them on the wrong date.
    def expiry_time_adjusted_for_daylight_savings
      if registered_in_bst_and_expires_in_gmt?
        registration.expires_on + 1.hour
      elsif registered_in_gmt_and_expires_in_bst?
        registration.expires_on - 1.hour
      else
        registration.expires_on
      end
    end

    def registered_in_bst_and_expires_in_gmt?
      registered_in_daylight_savings? && !expires_in_daylight_savings?
    end

    def registered_in_gmt_and_expires_in_bst?
      !registered_in_daylight_savings? && expires_in_daylight_savings?
    end

    def registered_in_daylight_savings?
      return true if registration.metaData.date_registered.in_time_zone("London").dst?

      false
    end

    def expires_in_daylight_savings?
      return true if registration.expires_on.in_time_zone("London").dst?

      false
    end
  end
end
