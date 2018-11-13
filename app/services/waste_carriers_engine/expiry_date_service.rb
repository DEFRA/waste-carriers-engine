# frozen_string_literal: true

module WasteCarriersEngine
  # Contains methods related to dealing with dates in the service, for example
  # whether a date would be considered as expired.
  class ExpiryDateService
    attr_reader :expiry_date, :registration_date

    def initialize(registration)
      raise "ExpiryDateService expects a registration" if registration.nil?

      @expiry_date = expires_on_date(registration.expires_on)
      @registration_date = registration.metaData.date_registered
    end

    # For more details about the renewal window check out
    # https://github.com/DEFRA/waste-carriers-renewals/wiki/Renewal-window
    def date_can_renew_from
      (@expiry_date - Rails.configuration.renewal_window.months)
    end

    def expired?
      # Registrations are expired on the date recorded for their expiry date e.g.
      # an expiry date of Mar 25 2018 means the registration was active up till
      # 24:00 on Mar 24 2018.
      return false if @expiry_date > Date.today

      true
    end

    def in_renewal_window?
      # If the registration expires in more than x months from now, its outside
      # the renewal window
      return true if @expiry_date < Rails.configuration.renewal_window.months.from_now

      false
    end

    # Its important to note that a registration is expired on its expires_on date.
    # For example if the expires_on date is Oct 1, then the registration was
    # ACTIVE Sept 30, and EXPIRED Oct 1. If the grace window is 3 days, just
    # adding 3 days to that date would give the impression the grace window lasts
    # till Oct 4 (i.e. 1 + 3) when in fact we need to include the 1st as one of
    # our grace window days.
    def in_expiry_grace_window?
      current_day = Date.today
      last_day_of_grace_window = (@expiry_date + Rails.configuration.grace_window.days) - 1.day

      current_day >= @expiry_date && current_day <= last_day_of_grace_window
    end

    private

    def expires_on_date(provided_date)
      return Date.new(1970, 1, 1) if provided_date.nil?

      provided_date
    end
  end
end
