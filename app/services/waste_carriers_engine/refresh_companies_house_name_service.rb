# frozen_string_literal: true

require "defra_ruby/companies_house"

module WasteCarriersEngine
  class RefreshCompaniesHouseNameService < WasteCarriersEngine::BaseService
    def run(reg_identifier:)
      registration = Registration.find_by(reg_identifier: reg_identifier)

      company_details = DefraRuby::CompaniesHouse::API.run(company_number: registration.company_no)

      registration.registered_company_name = company_details[:company_name]
      registration.companies_house_updated_at = Time.current
      registration.save!

      true
    end
  end
end
