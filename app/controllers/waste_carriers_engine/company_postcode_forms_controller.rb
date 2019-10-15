# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyPostcodeFormsController < PostcodeFormsController
    def new
      super(CompanyPostcodeForm, "company_postcode_form")
    end

    def create
      super(CompanyPostcodeForm, "company_postcode_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:company_postcode_form, {}).permit(:temp_company_postcode)
    end
  end
end
