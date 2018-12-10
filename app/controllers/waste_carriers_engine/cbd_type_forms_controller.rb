# frozen_string_literal: true

module WasteCarriersEngine
  class CbdTypeFormsController < FormsController
    def new
      super(CbdTypeForm, "cbd_type_form")
    end

    def create
      super(CbdTypeForm, "cbd_type_form")
    end
  end
end
