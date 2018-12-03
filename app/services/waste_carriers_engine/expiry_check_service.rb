# frozen_string_literal: true

module WasteCarriersEngine
  # Contains methods related to dealing with dates in the service, for example
  # whether a date would be considered as expired.
  class ExpiryCheckService
    attr_reader :expiry_date, :registration_date

    def initialize(registration)
      raise "ExpiryCheckService expects a registration" if registration.nil?

      @registration_date = registration.metaData.date_registered
      @expires_on = registration.expires_on
      @expiry_date = corrected_expires_on
    end

    # For more details about the renewal window check out
    # https://github.com/DEFRA/dst-guides/blob/master/services/wcr/renewal_window.md
    def date_can_renew_from
      (@expiry_date.to_date - Rails.configuration.renewal_window.months)
    end

    def expiry_date_after_renewal
      @expiry_date.to_date + Rails.configuration.expires_after.years
    end

    def expired?
      # Registrations are expired on the date recorded for their expiry date e.g.
      # an expiry date of Mar 25 2018 means the registration was active up till
      # 24:00 on Mar 24 2018.
      return false if @expiry_date.to_date > current_day

      true
    end

    def in_renewal_window?
      # If the registration expires in more than x months from now, its outside
      # the renewal window
      return true if @expiry_date.to_date < Rails.configuration.renewal_window.months.from_now

      false
    end

    # Its important to note that a registration is expired on its expires_on date.
    # For example if the expires_on date is Oct 1, then the registration was
    # ACTIVE Sept 30, and EXPIRED Oct 1. If the grace window is 3 days, just
    # adding 3 days to that date would give the impression the grace window lasts
    # till Oct 4 (i.e. 1 + 3) when in fact we need to include the 1st as one of
    # our grace window days.
    def in_expiry_grace_window?
      last_day_of_grace_window = (@expiry_date.to_date + Rails.configuration.grace_window.days) - 1.day

      current_day >= @expiry_date.to_date && current_day <= last_day_of_grace_window
    end

    private

    # expires_on is stored as a Time in UTC and then converted to a Date.
    # If a user first registered near midnight around the transition between GMT
    # and BST (or the other way round), there is a risk that the UTC date will
    # not be the same as the UK date. So compensate to avoid flagging something
    # as expired on the wrong date.
    def corrected_expires_on
      return Date.new(1970, 1, 1) if @expires_on.nil?
      return @expires_on + 1.hour if registered_in_bst_and_expires_in_gmt?
      return @expires_on - 1.hour if registered_in_gmt_and_expires_in_bst?

      @expires_on
    end

    def registered_in_bst_and_expires_in_gmt?
      registered_in_daylight_savings? && !expires_on_in_daylight_savings?
    end

    def registered_in_gmt_and_expires_in_bst?
      !registered_in_daylight_savings? && expires_on_in_daylight_savings?
    end

    def registered_in_daylight_savings?
      return true if @registration_date.in_time_zone("London").dst?

      false
    end

    def expires_on_in_daylight_savings?
      return true if @expires_on.in_time_zone("London").dst?

      false
    end

    # We store dates and times in UTC, but want to use the current date in the
    # UK, not necessarily UTC. For example a reg. that was
    # registered = Tue, 28 Mar 2017 00:30:00 BST +01:00
    # expires_on = Fri, 27 Mar 2020 23:30:00 +0000
    #
    # will have its expiry date corrected to
    # expiry_date = 28 Mar 2020 00:30:00 +0000
    #
    # If the current time was Tue, 31 Mar 2020 00:01:00 BST +01:00, but we just
    # called and used Date.Today we'd get Mon, 30 Mar 2020. Used in a method
    # like in_expiry_grace_window? with the grace window set to 3 would mean it
    # returns true when it should return false. Hence when referring to
    # to the current day, we should always be specific about the timezone we
    # are interested. In this example using current_day would return
    # Tue, 31 Mar 2020
    def current_day
      Time.now.in_time_zone("London").to_date
    end
  end
end
