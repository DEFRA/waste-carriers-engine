# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyTradingNameForm < ::WasteCarriersEngine::BaseForm
    delegate :business_type, :company_trading_name, to: :transient_registration

    validates :company_trading_name, "waste_carriers_engine/company_trading_name": true
  end
end
