# frozen_string_literal: true

module WasteCarriersEngine

  # This module contains shared presentation logic for carrier names.
  # This is similar to a model concern, but for presenters.
  module CanPresentCarrierName

    # For sole traders, we want to display the name of the trader. There
    # will only be one person, but the list_main_people method still works for
    # finding and formatting that single person.
    def carrier_name
      if upper_tier_sole_trader?
        list_main_people
      else
        company_registered_and_or_trading_name
      end
    end

    private

    def company_registered_and_or_trading_name
      if company_name.present?
        if registered_company_name.present?
          "#{registered_company_name} trading as #{company_name}"
        else
          company_name
        end
      else
        registered_company_name
      end
    end
  end
end
