# frozen_string_literal: true

module WasteCarriersEngine
  class CannotRenewCompanyNoChangeFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm

    def new
      super(CannotRenewCompanyNoChangeForm, "cannot_renew_company_no_change_form")
    end
  end
end
