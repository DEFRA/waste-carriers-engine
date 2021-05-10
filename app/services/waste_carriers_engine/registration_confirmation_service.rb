# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationConfirmationService < BaseService
    def run(registration)
      Notify::RegistrationConfirmationEmailService.run(registration: registration)
    end
  end
end
