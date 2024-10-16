# frozen_string_literal: true

module WasteCarriersEngine
  class ContactAddressForm < AddressLookupFormBase
    delegate :temp_contact_postcode, :contact_address, to: :transient_registration

    alias existing_address contact_address
    alias postcode temp_contact_postcode

    validates :contact_address, "waste_carriers_engine/address": true

    def submit(params)
      contact_address_params = params.fetch(:contact_address, {})
      contact_address = create_address(contact_address_params[:uprn], "POSTAL")

      super(contact_address: contact_address)
    end
  end
end
