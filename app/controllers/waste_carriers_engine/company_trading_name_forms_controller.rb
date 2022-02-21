# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyTradingNameFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(CompanyTradingNameForm, "company_trading_name_form")
    end

    def create
      super(CompanyTradingNameForm, "company_trading_name_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:company_trading_name_form, {}).permit(:company_trading_name)
    end
  end
end
