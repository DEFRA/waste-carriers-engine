# frozen_string_literal: true

module WasteCarriersEngine
  class ContactPostcodeFormsController < PostcodeFormsController
    def new
      super(ContactPostcodeForm, "contact_postcode_form")
    end

    def create
      super(ContactPostcodeForm, "contact_postcode_form")
    end
  end
end
