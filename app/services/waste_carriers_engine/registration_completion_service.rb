# frozen_string_literal: true

module WasteCarriersEngine
  class UnpaidBalanceError < StandardError; end
  class PendingConvictionsError < StandardError; end

  class RegistrationCompletionService < BaseService
    def run(registration:)
      @registration = registration

      activate_registration if can_be_completed?
    end

    private

    def activate_registration
      @registration.metaData.date_activated = Time.current
      @registration.metaData.activate!
    end

    def can_be_completed?
      balance_is_paid? && no_pending_conviction_check?
    end

    def balance_is_paid?
      raise UnpaidBalanceError if @registration.unpaid_balance?

      true
    end

    def no_pending_conviction_check?
      raise PendingConvictionsError if @registration.pending_manual_conviction_check?

      true
    end
  end
end
