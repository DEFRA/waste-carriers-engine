# frozen_string_literal: true

module WasteCarriersEngine

  # This module contains shared presentation logic for entity names.
  module CanPresentEntityDisplayName
    extend ActiveSupport::Concern

    # If both legal entity name and trading name are present, clean up the company name
    # if necessary and present legal entity name trading as company name.
    # Otherwise return whichever of the two names is present.
    def entity_display_name
      if company_name.present?
        trading_name = truncate_trading_as_name(company_name)
        if upper_tier? && legal_entity_name.present?
          "#{legal_entity_name} trading as #{trading_name}"
        else
          trading_name
        end
      else
        legal_entity_name
      end
    end

    private

    # If the name includes " trading as " or " t/a ", drop all text up to and including that.
    def truncate_trading_as_name(name)
      return name unless upper_tier?

      ["trading as", "t/a"].each do |term|
        includes_trading_as = name.match(/^.*\s#{term}\s+(.*)/i)
        return includes_trading_as[1] if includes_trading_as && includes_trading_as.length > 1
      end

      name
    end
  end
end
