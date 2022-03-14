# frozen_string_literal: true

require "defra_ruby_companies_house"

module WasteCarriersEngine
  class RefreshCompaniesHouseNameService < WasteCarriersEngine::BaseService
    def run(reg_identifier:)
      registration = Registration.find_by(reg_identifier: reg_identifier)

      company_name = DefraRubyCompaniesHouse.new(registration.company_no).company_name
      registration.registered_company_name = company_name
      registration.companies_house_updated_at = Time.current
      registration.save!

      true
    end
  end
end
