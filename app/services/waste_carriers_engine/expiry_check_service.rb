# frozen_string_literal: true

module WasteCarriersEngine
  # Contains methods related to dealing with dates in the service, for example
  # whether a date would be considered as expired.
  class ExpiryCheckService
    attr_reader :registration

    delegate :expires_on, to: :registration

    def initialize(registration)
      raise "ExpiryCheckService expects a registration" if registration.nil?

      @registration = registration
    end

    # For more details about the renewal window check out
    # https://github.com/DEFRA/dst-guides/blob/master/services/wcr/renewal_window.md
    def date_can_renew_from
      (expiry_date.to_date - Rails.configuration.renewal_window.months)
    end

    def expiry_date_after_renewal
      expiry_date.to_date + Rails.configuration.expires_after.years
    end

    def expired?
      # Registrations are expired on the date recorded for their expiry date e.g.
      # an expiry date of Mar 25 2018 means the registration was active up till
      # 24:00 on Mar 24 2018.
      expiry_date.to_date <= current_day
    end

    def in_renewal_window?
      # If the registration expires in more than x months from now, its outside
      # the renewal window
      expiry_date.to_date < Rails.configuration.renewal_window.months.from_now
    end

    # It's important to note that a registration is expired on its expires_on date.
    # For example if the expires_on date is Oct 1, then the registration was
    # ACTIVE Sept 30, and EXPIRED Oct 1. If the grace window is 3 days, just
    # adding 3 days to that date would give the impression the grace window lasts
    # till Oct 4 (i.e. 1 + 3) when in fact we need to include the 1st as one of
    # our grace window days.
    def in_expiry_grace_window?(ignore_extended_grace_window: false)
      last_day_of_grace_window = LastDayOfGraceWindowService.run(
        registration: registration,
        ignore_extended_grace_window: ignore_extended_grace_window
      )

      current_day_is_within_grace_window?(last_day_of_grace_window)
    end

    def expiry_date
      @_expiry_date ||= ExpiryDateService.run(registration: registration)
    end

    private

    def current_day_is_within_grace_window?(last_day_of_grace_window)
      current_day >= expiry_date.to_date && current_day <= last_day_of_grace_window
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
