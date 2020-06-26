# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationNumberFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(RegistrationNumberForm, "registration_number_form")
    end

    def create
      super(RegistrationNumberForm, "registration_number_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:registration_number_form, {}).permit(:company_no)
    end
  end
end
