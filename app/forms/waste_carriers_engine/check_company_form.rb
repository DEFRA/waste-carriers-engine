# frozen_string_literal: true

require "defra_ruby_companies_house"

module WasteCarriersEngine
  class CheckCompanyForm < ::WasteCarriersEngine::BaseForm
    delegate :company_no, :temp_use_companies_house_details, to: :transient_registration

    validates :temp_use_companies_house_details, "waste_carriers_engine/yes_no": true

    def ch_company_name
      company[:company_name]
    end

    def ch_registered_office_address_lines
      [
        company[:registered_office_address][:address_line_1],
        company[:registered_office_address][:address_line_2],
        company[:registered_office_address][:locality],
        company[:registered_office_address][:postal_code]
      ].compact
    end

    def ch_officer_names
      companies_house_service.active_officers.map do |officer|
        officer[:name].split(", ").reverse.join(" ")
      end
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
