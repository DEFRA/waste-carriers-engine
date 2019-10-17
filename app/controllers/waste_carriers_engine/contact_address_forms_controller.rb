# frozen_string_literal: true

module WasteCarriersEngine
  class ContactAddressFormsController < AddressFormsController
    def new
      super(ContactAddressForm, "contact_address_form")
    end

    def create
      super(ContactAddressForm, "contact_address_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:contact_address_form, {}).permit(contact_address: [:uprn])
    end
  end
end
