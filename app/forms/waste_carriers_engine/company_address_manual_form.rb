# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyAddressManualForm < ::WasteCarriersEngine::BaseForm
    include CanClearAddressFinderError
    include CanValidateManualAddress

    delegate :overseas?, :registered_address, :business_type, to: :transient_registration
    delegate :house_number, :address_line_1, :address_line_2, to: :registered_address, allow_nil: true
    delegate :postcode, :town_city, :country, to: :registered_address, allow_nil: true

    after_initialize :clean_address, unless: :saved_address_still_valid?

    def submit(params)
      address = Address.create_from_manual_entry(params[:registered_address] || {}, transient_registration.overseas?)
      address.assign_attributes(address_type: "REGISTERED")

      super(registered_address: address)
    end

    private

    def clean_address
      # Prefill the existing address unless the postcode has changed from the existing address's postcode
      transient_registration.registered_address = Address.new(
        address_type: "REGISTERED",
        postcode: transient_registration.temp_company_postcode
      )
    end

    def saved_address_still_valid?
      temp_postcode = transient_registration.temp_company_postcode

      overseas? || temp_postcode.nil? || temp_postcode == postcode
    end
  end
end
