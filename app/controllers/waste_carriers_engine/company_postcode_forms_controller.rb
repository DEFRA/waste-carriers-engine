# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyPostcodeFormsController < PostcodeFormsController
    def new
      super(CompanyPostcodeForm, "company_postcode_form")
    end

    def create
      super(CompanyPostcodeForm, "company_postcode_form")
    end
  end
end
