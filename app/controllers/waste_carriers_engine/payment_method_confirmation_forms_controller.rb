# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentMethodConfirmationFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(PaymentMethodConfirmationForm, "payment_method_confirmation_form")
    end

    def create
      super(PaymentMethodConfirmationForm, "payment_method_confirmation_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:payment_method_confirmation_form, {}).permit(:temp_confirm_payment_method)
    end
  end
end
