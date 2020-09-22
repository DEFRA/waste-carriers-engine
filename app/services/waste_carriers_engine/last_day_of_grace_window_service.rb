# frozen_string_literal: true

module WasteCarriersEngine
  # Works out which rules to apply to the grace period
  class LastDayOfGraceWindowService < BaseService
    attr_reader :registration, :current_user

    delegate :expires_on, to: :registration

    def run(registration:, current_user: nil)
      raise "ExpiryCheckService expects a registration" if registration.nil?

      @registration = registration
      @current_user = current_user

      run_grace_window_rules
    end

    private

    def run_grace_window_rules
      if extended_grace_window_available?
        last_day_of_extended_grace_window
      elsif registration_had_covid_extension?
        last_day_of_grace_window_with_covid_extension
      else
        last_day_of_standard_grace_window
      end
    end

    def extended_grace_window_available?
      return false unless current_user.present?

      FeatureToggle.active?(:use_extended_grace_window) && current_user.can?(:use_extended_grace_window, @registration)
    end

    def registration_had_covid_extension?
      end_of_covid_extension = Rails.configuration.end_of_covid_extension

      expiry_date < end_of_covid_extension
    end

    # The last day that you can add 3 years to a registration and have it still
    # be active.
    def last_day_of_extended_grace_window
      (expiry_date + Rails.configuration.expires_after.years) - 1.day
    end

    # This was an extended grace window applied from March to October 2020
    # to deal with decreased capacity due to COVID.
    def last_day_of_grace_window_with_covid_extension
      (expiry_date + Rails.configuration.covid_grace_window.days) - 1.day
    end

    # The default grace window with no extensions applied.
    def last_day_of_standard_grace_window
      (expiry_date + Rails.configuration.grace_window.days) - 1.day
    end

    def expiry_date
      @_expiry_date ||= ExpiryDateService.run(registration: registration).to_date
    end
  end
end
