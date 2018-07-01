module WasteCarriersEngine
  class CompanyNameFormsController < FormsController
    def new
      super(CompanyNameForm, "company_name_form")
    end

    def create
      super(CompanyNameForm, "company_name_form")
    end
  end
end
