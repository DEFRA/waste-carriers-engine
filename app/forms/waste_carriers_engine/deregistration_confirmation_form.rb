# frozen_string_literal: true

module WasteCarriersEngine
  # class DeregistrationConfirmationForm < ::WasteCarriersEngine::BaseForm
  class DeregistrationConfirmationForm
    def self.can_navigate_flexibly?
      false
    end

    def new
      render text: "Placeholder deregistration start form"
      super
    end

  end
end
