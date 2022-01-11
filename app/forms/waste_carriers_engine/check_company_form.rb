# frozen_string_literal: true

require "defra_ruby_companies_house"

module WasteCarriersEngine
  class CheckCompanyForm < ::WasteCarriersEngine::BaseForm
    delegate :company_no, :temp_use_companies_house_details, to: :transient_registration

    def ch_company_name
      company[:company_name]
    end

    private

    def company
      @_company ||= companies_house_service.company
    end

    def companies_house_service
      @_companies_house_service ||= DefraRubyCompaniesHouse.new(company_no)
    end
  end
end
