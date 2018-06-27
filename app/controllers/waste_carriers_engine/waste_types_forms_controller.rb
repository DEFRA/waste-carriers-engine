# frozen_string_literal: true

module WasteCarriersEngine
  class WasteTypesFormsController < FormsController
    def new
      super(WasteTypesForm, "waste_types_form")
    end

    def create
      super(WasteTypesForm, "waste_types_form")
    end
  end
end
