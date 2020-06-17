# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyAddressManualFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(CompanyAddressManualForm, "company_address_manual_form")
    end

    def create
      super(CompanyAddressManualForm, "company_address_manual_form")
    end

    private

    def transient_registration_attributes
      params
        .fetch(:company_address_manual_form, {})
        .permit(
          company_address: %i[house_number address_line_1 address_line_2 town_city postcode country]
        )
    end

  end
end
