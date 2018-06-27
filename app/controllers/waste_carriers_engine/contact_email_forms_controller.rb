# frozen_string_literal: true

module WasteCarriersEngine
  class ContactEmailFormsController < FormsController
    def new
      super(ContactEmailForm, "contact_email_form")
    end

    def create
      super(ContactEmailForm, "contact_email_form")
    end
  end
end
