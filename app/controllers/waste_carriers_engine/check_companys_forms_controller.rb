# frozen_string_literal: true

module WasteCarriersEngine
  class CheckCompanysFormsController < ::WasteCarriersEngine::FormsController

    def new
      super(CheckCompanyForm, "check_companys_form")
    end

    def create
      super(CheckCompanyForm, "check_company_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:check_company_form, {}).permit(:temp_use_companies_house_details)
    end
  end
end