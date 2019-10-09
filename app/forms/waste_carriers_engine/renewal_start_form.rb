# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStartForm < BaseForm
    def self.can_navigate_flexibly?
      false
    end

    def submit(params)
      attributes = {}

      super(attributes, params[:reg_identifier])
    end
  end
end
