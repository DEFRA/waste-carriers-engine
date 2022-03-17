# frozen_string_literal: true

module WasteCarriersEngine

  # This module contains shared presentation logic for carrier names.
  # This is similar to a model concern, but for presenters.
  module CanPresentEntityDisplayName

    # For sole traders, we want to display the name of the trader. There
    # will only be one person, but the list_main_people method still works for
    # finding and formatting that single person.
    def entity_display_name
      if upper_tier_sole_trader?
        legal_name_and_or_trading_name(list_main_people)
      else
        legal_name_and_or_trading_name(registered_company_name)
      end
    end

    def list_main_people
      list = main_people.map do |person|
        format("%<first>s %<last>s", first: person.first_name, last: person.last_name)
      end
      list.join("<br>").html_safe
    end

    private

    def upper_tier_sole_trader?
      upper_tier? && business_type == "soleTrader"
    end

    def legal_name_and_or_trading_name(legal_name)
      if company_name.present?
        trading_name = truncate_trading_as_name(company_name)
        if legal_name.present?
          "#{legal_name} trading as #{trading_name}"
        else
          trading_name
        end
      else
        legal_name
      end
    end

    # If the name includes " trading as " or " t/a ", drop all text up to and including that.
    def truncate_trading_as_name(name)
      ["trading as", "t/a"].each do |term|
        includes_trading_as = name.match(/^.*\s#{term}\s+(.*)/i)
        return includes_trading_as[1] if includes_trading_as && includes_trading_as.length > 1
      end

      name
    end
  end
end
