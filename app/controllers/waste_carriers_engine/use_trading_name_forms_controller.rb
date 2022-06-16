# frozen_string_literal: true

module WasteCarriersEngine
  class UseTradingNameFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(UseTradingNameForm, "use_trading_name_form")
    end

    def create
      super(UseTradingNameForm, "use_trading_name_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:use_trading_name_form, {}).permit(:temp_use_trading_name)
    end
  end
end
