# frozen_string_literal: true

module WasteCarriersEngine
  class ContactAddressManualFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(ContactAddressManualForm, "contact_address_manual_form")
    end

    def create
      super(ContactAddressManualForm, "contact_address_manual_form")
    end

    private

    def transient_registration_attributes
      params
        .fetch(:contact_address_manual_form, {})
        .permit(
          contact_address: %i[house_number address_line_1 address_line_2 town_city postcode country]
        )
    end
  end
end
