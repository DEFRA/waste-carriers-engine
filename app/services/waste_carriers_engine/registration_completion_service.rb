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
      raise_unpaid_balance_error if @registration.unpaid_balance?

      true
    end

    def raise_unpaid_balance_error
      raise "Registration #{@registration.reg_identifier} cannot be activated due to unpaid balance"
    end
  end
end
