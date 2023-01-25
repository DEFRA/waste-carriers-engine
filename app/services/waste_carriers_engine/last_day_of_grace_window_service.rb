# frozen_string_literal: true

module WasteCarriersEngine
  # Works out which rules to apply to the grace period
  class LastDayOfGraceWindowService < BaseService
    attr_reader :registration

    def run(registration:)
      raise "LastDayOfGraceWindowService expects a registration" if registration.nil?

      @registration = registration

      last_day_of_grace_window
    end

    private

    def last_day_of_grace_window
      (expiry_date + Rails.configuration.grace_window.days) - 1.day
    end

    def expiry_date
      @_expiry_date ||= ExpiryDateService.run(registration: registration).to_date
    end
  end
end
