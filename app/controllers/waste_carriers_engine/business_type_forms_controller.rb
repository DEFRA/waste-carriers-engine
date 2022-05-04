# frozen_string_literal: true

module WasteCarriersEngine
  class BusinessTypeFormsController < ::WasteCarriersEngine::FormsController
    include CanResetCompanyDetails

    def new
      super(BusinessTypeForm, "business_type_form")
    end

    def create
      super(BusinessTypeForm, "business_type_form")
      reset_company_attributes unless @transient_registration.company_no_required?
    end

    private

    def transient_registration_attributes
      params.fetch(:business_type_form, {}).permit(:business_type, :token)
    end
  end
end
