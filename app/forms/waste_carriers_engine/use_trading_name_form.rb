# frozen_string_literal: true

module WasteCarriersEngine
  class UseTradingNameForm < ::WasteCarriersEngine::BaseForm
    delegate :company_no, to: :transient_registration
    delegate :temp_use_trading_name, to: :transient_registration

    validates :temp_use_trading_name, "waste_carriers_engine/yes_no": true

  end
end
