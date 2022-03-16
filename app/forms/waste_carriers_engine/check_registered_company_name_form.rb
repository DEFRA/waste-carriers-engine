# frozen_string_literal: true

module WasteCarriersEngine
  class CheckRegisteredCompanyNameForm < ::WasteCarriersEngine::BaseForm
    delegate :company_no, to: :transient_registration

    def company_name
      companies_house_service.company_name
    end

    def registered_office_address_lines
      companies_house_service.registered_office_address_lines
    end

    private

    def companies_house_service
      @_companies_house_service ||= DefraRubyCompaniesHouse.new(company_no)
    end
  end
end
