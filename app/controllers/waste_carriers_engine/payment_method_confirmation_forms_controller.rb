# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentMethodConfirmationFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(PaymentMethodConfirmationForm, "payment_method_confirmation_form")
    end

    def create
      super(PaymentMethodConfirmationForm, "payment_method_confirmation_form")

      # If we land on this page with temp_govpay_next_url already set,
      # most likely the payment has failed or been cancelled on Gov.UK Pay and we've been redirected back.
      # So the existing transaction on Gov.UK Pay is in a terminal state.
      # So we need to start a new Gov.UK Pay payment.
      return unless @transient_registration.temp_govpay_next_url.present?

      govpay_service = GovpayPaymentService.new(@transient_registration,
                                                @transient_registration.finance_details.orders.last,
                                                current_user)
      govpay_service.prepare_for_payment
    end

    private

    def transient_registration_attributes
      params.fetch(:payment_method_confirmation_form, {}).permit(:temp_confirm_payment_method)
    end
  end
end
