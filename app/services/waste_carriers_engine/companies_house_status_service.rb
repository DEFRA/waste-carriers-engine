# frozen_string_literal: true

module WasteCarriersEngine
  class CompaniesHouseStatusService < BaseService
    PERMITTED_STATUSES = %i[active voluntary-arrangement liquidation].freeze

    def self.permitted_status?(company_status)
      PERMITTED_STATUSES.include?(company_status.to_s.to_sym)
    end
  end
end
