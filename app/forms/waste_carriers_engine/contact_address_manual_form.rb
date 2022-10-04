# frozen_string_literal: true

module WasteCarriersEngine
  class ContactAddressManualForm < ::WasteCarriersEngine::BaseForm
    include CanClearAddressFinderError
    include CanValidateManualAddress

    delegate :overseas?, :contact_address, to: :transient_registration
    delegate :house_number, :address_line_1, :postcode, to: :contact_address, allow_nil: true
    delegate :address_line_2, :town_city, :country, to: :contact_address, allow_nil: true

    after_initialize :clean_address, unless: :saved_address_still_valid?

    def submit(params)
      address = Address.create_from_manual_entry(params[:contact_address] || {}, transient_registration.overseas?)
      address.assign_attributes(address_type: "POSTAL")

      super(contact_address: address)
    end

    private

    def clean_address
      # Prefill the existing address unless the postcode has changed from the existing address's postcode
      transient_registration.contact_address = Address.new(
        postcode: transient_registration.temp_contact_postcode
      )
    end

    def saved_address_still_valid?
      temp_postcode = transient_registration.temp_contact_postcode

      overseas? || temp_postcode.nil? || temp_postcode == postcode
    end
  end
end
