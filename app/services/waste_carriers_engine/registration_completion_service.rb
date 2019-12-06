# frozen_string_literal: true

module WasteCarriersEngine
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
      if @registration.unpaid_balance?
        raise_unpaid_balance_error
      else
        true
      end
    end

    def no_pending_conviction_check?
      if @registration.pending_manual_conviction_check?
        raise_convictions_check_error
      else
        true
      end
    end

    def raise_unpaid_balance_error
      raise "Registration #{@registration.reg_identifier} cannot be activated due to unpaid balance"
    end

    def raise_convictions_check_error
      raise "Registration #{@registration.reg_identifier} cannot be activated due to pending convictions check"
    end
  end
end
