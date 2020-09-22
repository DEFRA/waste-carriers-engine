# frozen_string_literal: true

module WasteCarriersEngine
  # Responsible for returning the "true" expiry date, accounting for differences
  # in daylight savings time.
  class ExpiryDateService < BaseService
    delegate :expires_on, to: :registration

    attr_reader :registration

    def run(registration:)
      @registration = registration

      corrected_expires_on
    end

    private

    def registration_date
      @_registration_date ||= registration.metaData.date_registered
    end

    # expires_on is stored as a Time in UTC and then converted to a Date.
    # If a user first registered near midnight around the transition between GMT
    # and BST (or the other way round), there is a risk that the UTC date will
    # not be the same as the UK date. So compensate to avoid flagging something
    # as expired on the wrong date.
    def corrected_expires_on
      return if expires_on.nil?
      return expires_on + 1.hour if registered_in_bst_and_expires_in_gmt?
      return expires_on - 1.hour if registered_in_gmt_and_expires_in_bst?

      expires_on
    end

    def registered_in_bst_and_expires_in_gmt?
      registered_in_daylight_savings? && !expires_on_in_daylight_savings?
    end

    def registered_in_gmt_and_expires_in_bst?
      !registered_in_daylight_savings? && expires_on_in_daylight_savings?
    end

    def registered_in_daylight_savings?
      registration_date.in_time_zone("London").dst?
    end

    def expires_on_in_daylight_savings?
      expires_on.in_time_zone("London").dst?
    end
  end
end
