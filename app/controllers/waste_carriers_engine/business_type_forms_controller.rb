# frozen_string_literal: true

module WasteCarriersEngine
  class BusinessTypeFormsController < ::WasteCarriersEngine::FormsController
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

    # Clear any previous business-type specific attributes to handle cases where the user
    # starts with one business type and then navigates back and changes the business type.
    def reset_company_attributes
      @transient_registration.company_no = nil
      @transient_registration.registered_company_name = nil
      @transient_registration.temp_use_registered_company_details = nil
      @transient_registration.save!
    end
  end
end
