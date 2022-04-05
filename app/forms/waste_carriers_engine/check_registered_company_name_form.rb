# frozen_string_literal: true

module WasteCarriersEngine
  class CheckRegisteredCompanyNameForm < ::WasteCarriersEngine::BaseForm
    delegate :company_no, to: :transient_registration
    delegate :registered_company_name, to: :transient_registration
    delegate :temp_use_registered_company_details, to: :transient_registration
    validates :temp_use_registered_company_details, "waste_carriers_engine/yes_no": true

    def registered_company_name
      companies_house_service.company_name
    end

    def registered_office_address_lines
      companies_house_service.registered_office_address_lines
    end

    def submit(params)
      params[:registered_company_name] = registered_company_name

      # Any existing company name should not be used for a registration renewal where company_name is optional.
      params[:company_name] = nil unless transient_registration.company_name_required?

      super
    end

    private

    def companies_house_service
      @_companies_house_service ||= DefraRubyCompaniesHouse.new(company_no)
    end
  end
end
