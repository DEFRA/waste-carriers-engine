# frozen_string_literal: true

module WasteCarriersEngine
  class DeregistrationConfirmationFormsController < WasteCarriersEngine::FormsController

    def new
      super(DeregistrationConfirmationForm, "deregistration_confirmation_form")
    end

    def create
      find_or_initialize_transient_registration(params[:token])

      return unless super(DeregistrationConfirmationForm, "deregistration_confirmation_form")

      if transient_registration_attributes[:temp_confirm_deregistration] == "yes"
        RegistrationDeactivationService.run(registration: @transient_registration.registration)
      else
        @transient_registration.destroy!
      end
    end

    private

    def find_or_initialize_transient_registration(token)
      @transient_registration = DeregisteringRegistration.where(token: token).first
      if @transient_registration.present?
        # If a DeregisteringRegistration already exists, reset its workflow state to the beginning
        @transient_registration.update_attributes(workflow_state: "deregistration_confirmation_form")
      else
        @transient_registration = DeregisteringRegistration.new(token: token)
      end
    end

    def transient_registration_attributes
      params.fetch(:deregistration_confirmation_form, {}).permit(:temp_confirm_deregistration)
    end
  end
end
