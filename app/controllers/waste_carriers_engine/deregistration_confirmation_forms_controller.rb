# frozen_string_literal: true

module WasteCarriersEngine
  class DeregistrationConfirmationFormsController < WasteCarriersEngine::FormsController

    def new
      super(DeregistrationConfirmationForm, "deregistration_confirmation_form")
    end

    def create
      find_or_initialize_transient_registration(params[:token])

      return unless super(DeregistrationConfirmationForm, "deregistration_confirmation_form")

      return unless transient_registration_attributes[:temp_confirm_deregistration] == "yes"

      RegistrationDeactivationService.run(registration: @transient_registration.registration)
    end

    private

    def find_or_initialize_transient_registration(token)
      @transient_registration = DeregisteringRegistration.where(reg_identifier: token).first ||
                                DeregisteringRegistration.where(token: token).first ||
                                DeregisteringRegistration.new(reg_identifier: token)
    end

    def transient_registration_attributes
      params.fetch(:deregistration_confirmation_form, {}).permit(:temp_confirm_deregistration)
    end
  end
end
