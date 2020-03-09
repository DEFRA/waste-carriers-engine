# frozen_string_literal: true

module WasteCarriersEngine
  class RenewRegistrationFormsController < FormsController
    def new
      super(RenewRegistrationForm, "renew_registration_form")
    end

    def create
      super(RenewRegistrationForm, "renew_registration_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:renew_registration_form, {})
    end
  end
end
