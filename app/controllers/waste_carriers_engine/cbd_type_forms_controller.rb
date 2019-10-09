# frozen_string_literal: true

module WasteCarriersEngine
  class CbdTypeFormsController < FormsController
    def new
      super(CbdTypeForm, "cbd_type_form")
    end

    def create
      super(CbdTypeForm, "cbd_type_form")
    end

    private

    def transient_registration_attributes
      params.require(:cbd_type_form).permit(:registration_type)
    end
  end
end
