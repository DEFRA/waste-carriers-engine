# frozen_string_literal: true

module WasteCarriersEngine
  class BusinessTypeFormsController < FormsController
    def new
      super(BusinessTypeForm, "business_type_form")
    end

    def create
      super(BusinessTypeForm, "business_type_form")
    end

    private

    def transient_registration_attributes
      params.require(:business_type_form).permit(:business_type, :reg_identifier)
    end
  end
end
