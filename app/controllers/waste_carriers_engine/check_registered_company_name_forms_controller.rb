# frozen_string_literal: true

require "defra_ruby_companies_house"

module WasteCarriersEngine
  class CheckRegisteredCompanyNameFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(CheckRegisteredCompanyNameForm, "check_registered_company_name_form")

      begin
        company_name
      rescue StandardError => e
        Rails.logger.error "Failed to load: #{e}"
        render(:companies_house_down)
      end
    end

    def create
      super(CheckRegisteredCompanyNameForm, "check_registered_company_name_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:check_registered_company_name_form, {}).permit(:temp_use_registered_company_details, :token)
    end

    def company_name
      DefraRubyCompaniesHouse.new(@transient_registration.company_no).company_name
    end
  end
end
