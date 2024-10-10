# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyAddressForm < AddressLookupFormBase
    delegate :temp_company_postcode, :business_type, :registered_address, to: :transient_registration

    alias postcode temp_company_postcode

    validates :registered_address, "waste_carriers_engine/address": true

    def submit(params)
      address_params = params.fetch(:registered_address, {})
      registered_address = create_address(address_params[:uprn], "REGISTERED")

      super(registered_address:)
    end
  end
end
