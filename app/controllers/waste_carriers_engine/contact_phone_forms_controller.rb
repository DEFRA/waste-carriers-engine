# frozen_string_literal: true

module WasteCarriersEngine
  class ContactPhoneFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(ContactPhoneForm, "contact_phone_form")
    end

    def create
      super(ContactPhoneForm, "contact_phone_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:contact_phone_form, {}).permit(:phone_number)
    end
  end
end
