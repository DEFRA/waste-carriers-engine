# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationReceivedPendingWorldpayPaymentFormsController < FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    def new
      return unless super(
        RegistrationReceivedPendingWorldpayPaymentForm,
        "registration_received_pending_worldpay_payment_form"
      )

      begin
        @registration = RegistrationCompletionService.run(@transient_registration)
      rescue StandardError => e
        Airbrake.notify(e, reg_identifier: @transient_registration.reg_identifier)
        Rails.logger.error e
      end
    end
  end
end
