# frozen_string_literal: true

module WasteCarriersEngine
  class InvalidCompanyStatusFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(InvalidCompanyStatusForm, "invalid_company_status_form")
    end

    def create
      super(InvalidCompanyStatusForm, "invalid_company_status_form")
    end
  end
end
