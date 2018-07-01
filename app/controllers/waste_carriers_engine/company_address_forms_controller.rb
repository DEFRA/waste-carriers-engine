module WasteCarriersEngine
  class CompanyAddressFormsController < AddressFormsController
    def new
      super(CompanyAddressForm, "company_address_form")
    end

    def create
      super(CompanyAddressForm, "company_address_form")
    end
  end
end
