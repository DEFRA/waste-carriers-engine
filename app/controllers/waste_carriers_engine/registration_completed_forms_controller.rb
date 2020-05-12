# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationCompletedFormsController < FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    def new
      return unless super(RegistrationCompletedForm, "registration_completed_form")

      begin
        @registration = RegistrationCompletionService.run(@transient_registration)
      rescue StandardError => e
        Airbrake.notify(e, reg_identifier: @transient_registration.reg_identifier)
        Rails.logger.error e
      end
    end
  end
end
