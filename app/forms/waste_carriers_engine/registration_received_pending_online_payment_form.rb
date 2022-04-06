# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationReceivedPendingOnlinePaymentForm < ::WasteCarriersEngine::BaseForm
    include CannotSubmit

    def self.can_navigate_flexibly?
      false
    end
  end
end
