# frozen_string_literal: true

module WasteCarriersEngine
  class WasteTypesFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(WasteTypesForm, "waste_types_form")
    end

    def create
      super(WasteTypesForm, "waste_types_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:waste_types_form, {}).permit(:only_amf)
    end
  end
end
