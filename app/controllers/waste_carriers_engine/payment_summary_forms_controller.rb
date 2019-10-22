# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentSummaryFormsController < FormsController
    def new
      super(PaymentSummaryForm, "payment_summary_form")
    end

    def create
      super(PaymentSummaryForm, "payment_summary_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:payment_summary_form, {}).permit(:temp_payment_method)
    end
  end
end
