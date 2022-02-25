# frozen_string_literal: true

module WasteCarriersEngine
  class CheckRegisteredCompanyNameFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(CheckRegisteredCompanyNameForm, "check_registered_company_name_form")
    end

    def create
      super(CheckRegisteredCompanyNameForm, "check_registered_company_name_form")
    end
  end
end