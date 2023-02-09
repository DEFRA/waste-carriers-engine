# frozen_string_literal: true

module WasteCarriersEngine
  class DeregistrationCompleteForm < WasteCarriersEngine::BaseForm
    include CannotGoBackForm
    include CannotSubmit

    def self.can_navigate_flexibly?
      false
    end
  end
end
