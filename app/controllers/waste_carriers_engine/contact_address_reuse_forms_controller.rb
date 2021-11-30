# frozen_string_literal: true

module WasteCarriersEngine
  class ContactAddressReuseFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(ContactAddressReuseForm, "contact_address_reuse_form")
    end

    def create
      super(ContactAddressReuseForm, "contact_address_reuse_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:contact_address_reuse_form, {}).permit(:temp_reuse_registered_address)
    end
  end
end
