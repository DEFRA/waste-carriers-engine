# frozen_string_literal: true

module WasteCarriersEngine
  class BusinessNameFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(BusinessNameForm, "business_name_form")
    end

    def create
      super(BusinessNameForm, "business_name_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:business_name_form, {}).permit(:business_name)
    end
  end
end
