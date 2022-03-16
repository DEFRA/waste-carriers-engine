# frozen_string_literal: true

module WasteCarriersEngine
  class IncorrectCompanyFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(IncorrectCompanyForm, "incorrect_company_form")
    end

    def create
      super(IncorrectCompanyForm, "incorrect_company_form")
    end
  end
end
