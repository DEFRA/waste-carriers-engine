# frozen_string_literal: true

module WasteCarriersEngine
  class RegisterInWalesForm < BaseForm
    def initialize(transient_registration)
      super
    end

    def submit(_params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      attributes = {}

      super(attributes)
    end
  end
end
