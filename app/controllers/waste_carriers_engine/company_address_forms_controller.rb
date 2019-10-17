# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyAddressFormsController < AddressFormsController
    def new
      super(CompanyAddressForm, "company_address_form")
    end

    def create
      super(CompanyAddressForm, "company_address_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:company_address_form, {}).permit(company_address: [:uprn])
    end
  end
end
