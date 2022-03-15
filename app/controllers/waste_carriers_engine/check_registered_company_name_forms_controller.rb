# frozen_string_literal: true

require "defra_ruby_companies_house"

module WasteCarriersEngine
  class CheckRegisteredCompanyNameFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(CheckRegisteredCompanyNameForm, "check_registered_company_name_form")
    end

    def create
      super(CheckRegisteredCompanyNameForm, "check_registered_company_name_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:check_registered_company_name_form, {}).permit(:temp_use_registered_company_details, :token)
    end
  end
end
