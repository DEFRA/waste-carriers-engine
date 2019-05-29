# frozen_string_literal: true

module WasteCarriersEngine
  class WorldpayForm < BaseForm
    def self.can_navigate_flexibly?
      false
    end

    def initialize(transient_registration)
      super
    end
  end
end
