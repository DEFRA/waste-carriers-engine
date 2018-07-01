module WasteCarriersEngine
  class CannotRenewCompanyNoChangeFormsController < FormsController
    def new
      super(CannotRenewCompanyNoChangeForm, "cannot_renew_company_no_change_form")
    end

    # Override this method as user shouldn't be able to "submit" this page
    def create; end
  end
end
