# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationReceivedPendingConvictionForm < ::WasteCarriersEngine::BaseForm
    include CannotSubmit

    def self.can_navigate_flexibly?
      false
    end
  end
end
