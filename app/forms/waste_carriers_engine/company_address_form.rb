# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyAddressForm < AddressLookupFormBase
    delegate :temp_company_postcode, :business_type, :company_address, to: :transient_registration

    alias existing_address company_address
    alias postcode temp_company_postcode

    validates :company_address, "waste_carriers_engine/address": true

    def submit(params)
      company_address_params = params.fetch(:company_address, {})
      company_address = create_address(company_address_params[:uprn], "REGISTERED")

      super(company_address: company_address)
    end
  end
end
