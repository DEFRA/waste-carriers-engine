# frozen_string_literal: true

module WasteCarriersEngine
  class CheckCompanysFormsController < ::WasteCarriersEngine::FormsController

    def new
      super(CheckCompanysForm, "check_companys_form")
    end

    def create
      super(CheckCompanysForm, "check_companys_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:check_companys_form, {}).permit(:temp_use_companies_house_details)
    end
  end
end