# frozen_string_literal: true

module WasteCarriersEngine
  class ContactPostcodeForm < PostcodeForm
    attr_accessor :temp_contact_postcode

    validates :temp_contact_postcode, "waste_carriers_engine/postcode": true

    def initialize(transient_registration)
      super

      self.temp_contact_postcode = transient_registration.temp_contact_postcode
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.temp_contact_postcode = format_postcode(params[:temp_contact_postcode])
      attributes = { temp_contact_postcode: temp_contact_postcode }

      # While we won't proceed if the postcode isn't valid, we always save it in case it's needed for manual entry
      transient_registration.update_attributes(attributes)

      super(attributes)
    end
  end
end
