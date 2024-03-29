# frozen_string_literal: true

module WasteCarriersEngine
  class ContactPostcodeForm < PostcodeForm
    delegate :temp_contact_postcode, to: :transient_registration

    validates :temp_contact_postcode, "defra_ruby/validators/postcode": true
    validates :temp_contact_postcode, "waste_carriers_engine/address_lookup": true

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      params[:temp_contact_postcode] = format_postcode(params[:temp_contact_postcode])

      # While we won't proceed if the postcode isn't valid, we always save it in case it's needed for manual entry
      transient_registration.update_attributes(params)

      super
    end
  end
end
