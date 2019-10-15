# frozen_string_literal: true

module WasteCarriersEngine
  class ContactNameFormsController < FormsController
    def new
      super(ContactNameForm, "contact_name_form")
    end

    def create
      super(ContactNameForm, "contact_name_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:contact_name_form, {}).permit(:first_name, :last_name)
    end
  end
end
