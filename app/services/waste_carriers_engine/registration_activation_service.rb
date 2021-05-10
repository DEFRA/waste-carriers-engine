# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationActivationService < BaseService
    def run(registration:)
      @registration = registration

      return unless can_be_completed?

      registration.with_lock do
        activate_registration
      end

      send_registration_confirmation
    end

    private

    def activate_registration
      @registration.metaData.date_activated = Time.current
      @registration.metaData.activate!
    end

    def can_be_completed?
      balance_is_paid? && no_pending_conviction_check? && correct_status?
    end

    def balance_is_paid?
      !@registration.unpaid_balance?
    end

    def correct_status?
      @registration.pending?
    end

    def no_pending_conviction_check?
      !@registration.pending_manual_conviction_check?
    end

    def send_registration_confirmation
      RegistrationConfirmationService.run(registration: @registration)
    end
  end
end
