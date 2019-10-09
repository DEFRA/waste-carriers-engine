# frozen_string_literal: true

module WasteCarriersEngine
  class RegisterInWalesForm < BaseForm
    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      attributes = {}

      super(attributes, params[:reg_identifier])
    end
  end
end
