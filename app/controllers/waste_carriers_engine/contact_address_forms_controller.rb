# frozen_string_literal: true

module WasteCarriersEngine
  class ContactAddressFormsController < AddressFormsController
    def new
      super(ContactAddressForm, "contact_address_form")
    end

    def create
      super(ContactAddressForm, "contact_address_form")
    end
  end
end
