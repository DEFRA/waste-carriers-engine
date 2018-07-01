module WasteCarriersEngine
  class CompanyAddressManualForm < ManualAddressForm
    include CanNavigateFlexibly

    private

    def saved_temp_postcode
      @transient_registration.temp_company_postcode
    end

    def existing_address
      @transient_registration.registered_address
    end

    def address_type
      "REGISTERED"
    end
  end
end
