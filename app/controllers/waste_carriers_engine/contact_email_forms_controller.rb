# frozen_string_literal: true

module WasteCarriersEngine
  class ContactEmailFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(ContactEmailForm, "contact_email_form")
    end

    def create
      super(ContactEmailForm, "contact_email_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:contact_email_form, {}).permit(:contact_email, :confirmed_email, :no_contact_email)
    end
  end
end
