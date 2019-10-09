# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStartForm < BaseForm
    def self.can_navigate_flexibly?
      false
    end

    def submit(_params)
      attributes = {}

      super(attributes)
    end
  end
end
